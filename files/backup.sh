#!/bin/bash -e

unset_vars() {
  unset GPG_PHRASE
  unset CONSUL_HTTP_TOKEN
  unset ACCESS_KEY
  unset SECRET_KEY
}

clean_environment(){
  rm -f consul-backup-*.snap
  rm -f /tmp/tmpfile-*
  unset_vars
}
trap clean_environment EXIT

# Log to stdout for kubernetes
log() {
  echo "$1"
}

# If we want daily backups, we might want to change this
BACKUP_FILE="consul-backup-$(date +"%H-%M-%S").snap"
S3_BACKUP_DIR="$(date +"%Y")/$(date +"%m")/$(date +"%d")"

# Get CONSUL_HTTP_TOKEN, GPG_PHRASE, ACCESS_KEY and SECRET_KEY
source /environment.sh

# Backup consul
log "Using CONSUL_HTTP_ADDR: ${CONSUL_HTTP_ADDR}"
log "Running consul snapshot save"
consul snapshot save ${BACKUP_FILE} || log "ERROR: Failed to save consul snapshot" && exit 1
log "Consul snapshot saved" 

# Inspect the backup
consul snapshot inspect ${BACKUP_FILE} || log "ERROR: Consul backup failed inspection" && exit 1


# Push to S3
log "Uploading snapshot to S3"
s3cmd put  ${BACKUP_FILE} s3://${S3_BUCKET}/${S3_BACKUP_DIR}/${BACKUP_FILE} || log "ERROR: Failed to upload snapshot to S3" && exit 1
log "Snapshot uploaded to S3"
