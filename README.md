# Safe kubectl

Plugin to add some safety when running kubectl. When there are kubernetes clusters you still run `kubectl` against but you want confidence through periodic reminders you can install this zsh plugin.

## Installing
1. Clone the custom repo
    ```
    cd $HOME/.oh-my-zsh/custom/plugins
    git clone https://github.com/benjefferies/safe-kubectl
    ```
1.  Add the safe-kubectl plugin in your `$HOME/.zshrc` [plugins](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins) e.g.
    ```
    plugins=(git kubectl safe-kubectl)
    ```
1. Reload or `source $HOME/.zshrc`

## Customising

* `KUBECTL_PATH` - Set the path where kubectl is
* `KUBECTL_SAFE_CLUSTERS` - Set clusters you want to exclude from safety checks
* `KUBECTL_SAFE_TIME` - Set the safe time you can run a kubectl command within without safety prompt
