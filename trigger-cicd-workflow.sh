#!/usr/bin/env bash
set -euo pipefail

# 1) Stage & commit
echo "→ git add ."
git add .

echo '→ git commit -m "new"'
git commit -m "new" || true

# 2) Push to GitHub
echo "→ git push to GitHub"
git push "https://${GIT_USER}:${GITHUB_TOKEN}@${GIT_REPO}" main

# 3) Trigger Jenkins build
echo "→ fetching Jenkins CSRF crumb…"
CRUMB=$(curl -s --user "${JENKINS_USER}:${JENKINS_API_TOKEN}" \
  "${JENKINS_URL}/crumbIssuer/api/json" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["crumb"])'
)

echo "→ reading nextBuildNumber…"
NEXT=$(curl -s --user "${JENKINS_USER}:${JENKINS_API_TOKEN}" \
  "${JENKINS_URL}/job/${JOB_NAME}/api/json?tree=nextBuildNumber" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["nextBuildNumber"])'
)
echo "   will trigger build #${NEXT}"

echo "→ triggering Jenkins job ${JOB_NAME}"
curl -s -X POST \
  --user "${JENKINS_USER}:${JENKINS_API_TOKEN}" \
  -H "Jenkins-Crumb: ${CRUMB}" \
  "${JENKINS_URL}/job/${JOB_NAME}/build" > /dev/null

# 4) Wait for the build to appear
echo "→ waiting for build #${NEXT} to start…"
until curl -s --user "${JENKINS_USER}:${JENKINS_API_TOKEN}" \
    "${JENKINS_URL}/job/${JOB_NAME}/${NEXT}/api/json" &> /dev/null; do
  sleep 1
done

# 5) Poll build status with Bash regex
POLL_INTERVAL=10
echo "→ build #${NEXT} started. Polling every ${POLL_INTERVAL}s…"
while true; do
  DATA=$(curl -s --user "${JENKINS_USER}:${JENKINS_API_TOKEN}" \
    "${JENKINS_URL}/job/${JOB_NAME}/${NEXT}/api/json?tree=building,result")

  if [[ $DATA =~ \"building\":(true|false) ]]; then
    BUILDING=${BASH_REMATCH[1]}
  else
    BUILDING=""
  fi

  if [[ $DATA =~ \"result\":\"([A-Z]+)\" ]]; then
    RESULT=${BASH_REMATCH[1]}
  else
    RESULT=""
  fi

  if [ -z "$BUILDING" ]; then
    echo "   waiting for build info…"
    sleep $POLL_INTERVAL
    continue
  fi

  if [ "$BUILDING" = "true" ]; then
    echo "   still building…"
    sleep $POLL_INTERVAL
    continue
  fi

  echo "→ build #${NEXT} finished with status: ${RESULT:-UNKNOWN}"
  break
done

# 6) On success, pull; otherwise exit non-zero
if [ "${RESULT}" = "SUCCESS" ]; then
  echo "→ build succeeded! Running git pull…"
  git pull "https://${GIT_USER}:${GITHUB_TOKEN}@${GIT_REPO}" main
  echo "✔ Repository synced."
  exit 0
else
  echo "✖ Build failed (status: ${RESULT}). No pull executed."
  exit 1
fi
