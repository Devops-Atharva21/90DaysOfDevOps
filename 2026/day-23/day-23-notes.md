###What is a branch in Git?

A branch is an independent line of development in Git. It allows you to work on new features, bug fixes, or experiments without affecting the main codebase.

###Why do we use branches instead of committing everything to main?

Branches keep the main branch stable and production-ready. Developers can work independently and merge changes only after testing.

###What is HEAD in Git?

HEAD is a pointer that indicates the currently checked-out branch or commit. It tells Git where you are in the repository.

###What happens to your files when you switch branches?

Git updates your working directory to match the selected branch. Files may appear, disappear, or change depending on the branch's commits

##Difference between origin and upstream

origin

Your default remote repository.
Usually points to your own GitHub repository.

upstream

The original repository from which a fork was created.
Used to receive updates from the original project.

###Difference between git fetch and git pull

--git fetch

Downloads changes but does not merge them.

git fetch origin

--git pull

Downloads and immediately merges changes.

git pull origin main
Summary
fetch = download only
pull  = download + merge

###When would you clone vs fork?

---Clone
Use when:
Working on your own repository.
You have direct access.

--Fork
Use when:
Contributing to open-source projects.
You don't have write access to the original repository.
