#!/bin/sh
set -e

REGISTRY_URL="http://registry:5000"
KEEP_LAST_N=3

apk add --no-cache curl jq > /dev/null 2>&1

echo "Starting registry GC service..."
sleep 60

while true; do
    echo "$(date): Starting tag cleanup..."

    for repo in $(curl -sf "${REGISTRY_URL}/v2/_catalog" | jq -r '.repositories[]?'); do
        tags_json=$(curl -sf "${REGISTRY_URL}/v2/${repo}/tags/list")
        total=$(echo "${tags_json}" | jq '.tags | length // 0')

        if [ "${total}" -gt "${KEEP_LAST_N}" ]; then
            to_delete=$((total - KEEP_LAST_N))
            echo "  ${repo}: keeping ${KEEP_LAST_N} of ${total} tags, deleting ${to_delete}"

            echo "${tags_json}" | jq -r '.tags[]?' | sort -V | head -n "${to_delete}" | while IFS= read -r tag; do
                digest=$(curl -sf -I \
                    -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
                    "${REGISTRY_URL}/v2/${repo}/manifests/${tag}" | \
                    grep -i "Docker-Content-Digest" | \
                    awk '{print $2}' | \
                    tr -d '\r')
                if [ -n "${digest}" ]; then
                    echo "    Deleting ${repo}:${tag} (${digest})"
                    curl -sf -X DELETE "${REGISTRY_URL}/v2/${repo}/manifests/${digest}" || true
                fi
            done
        fi
    done

    echo "$(date): Running garbage collection..."
    /bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml
    echo "$(date): Cleanup complete. Sleeping for 24 hours..."
    sleep 86400
done
