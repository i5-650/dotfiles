function gca!
    git commit --verbose --all --amend
end

function gpf
    git push --force-with-lease --force-if-includes
end
