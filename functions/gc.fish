function gc --wraps='git diff --name-only --diff-filter=U --relative' --description 'alias gc=git diff --name-only --diff-filter=U --relative'
  git diff --name-only --diff-filter=U --relative $argv
        
end
