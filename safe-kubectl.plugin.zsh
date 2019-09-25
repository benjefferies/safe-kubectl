export KUBECTL_PATH=$(which kubectl)

if uname | grep -q "Darwin"; then
    __MOD_TIME_FMT="-f %m"
    __SED_I_CMD="-i ''"
else
    __MOD_TIME_FMT="-c %Y"
    __SED_I_CMD="-i"
fi

if (( $+commands[kubectl] )); then
    __KUBECTL_COMPLETION_FILE="${ZSH_CACHE_DIR}/kubectl_completion"

    if [[ ! -f $__KUBECTL_COMPLETION_FILE ]]; then
        kubectl completion zsh >! $__KUBECTL_COMPLETION_FILE
    fi

    [[ -f $__KUBECTL_COMPLETION_FILE ]] && sed $__SED_I_CMD 's|$(kubectl\ |$('${KUBECTL_PATH}' |g' $__KUBECTL_COMPLETION_FILE && source $__KUBECTL_COMPLETION_FILE

    unset __KUBECTL_COMPLETION_FILE
fi

safe_operations="completion api-versions cluster-info config describe diff explain get logs version"

safe_kubectl() {
  context=$($KUBECTL_PATH config current-context)
  setopt shwordsplit
  for cluster in $KUBECTL_SAFE_CLUSTERS
  do
    if [ $cluster = $context ]; then
      $KUBECTL_PATH $*
      return
    fi
  done

  op=$1
  for safe_op in $safe_operations
  do
    if [ $safe_op = $op ]; then
      $KUBECTL_PATH $*
      return
    fi
  done

  last_kubectl=$(stat $__MOD_TIME_FMT $HOME/.safe_kubectl/context)
  touch $HOME/.safe_kubectl/context
  epoch_now=$(date +%s)
  seconds_since_last_kubectl=$(($epoch_now - last_kubectl))

  # Allow run without prompt within $KUBECTL_SAFE_TIME
  if [ $seconds_since_last_kubectl -lt ${KUBECTL_SAFE_TIME:-300} ]; then
    $KUBECTL_PATH $*
    return
  fi

  echo "It's been $seconds_since_last_kubectl seconds since last running kubectl. Context is \033[31m$context\e[0m"
  echo "Are you sure you want to run \033[31mkubectl $*\e[0m?"
  select result in "Yes" "No"
  do
    case $result in
      Yes)
        $KUBECTL_PATH $*
        break
        ;;
      No)
        echo "Cancelled"
        break
        ;;
      *)
        echo "$result is not a valid option. Cancelled"
        break
        ;;
	  esac
  done
}

# Initial setup
mkdir -p $HOME/.safe_kubectl
if [ ! -f $HOME/.safe_kubectl/context ]; then
  touch $HOME/.safe_kubectl/context
fi

# Alias wrapper script
alias kubectl=safe_kubectl
compdef safe_kubectl=kubectl
