# Day 25 Notes – Git Reset

## 1. Difference between `--soft`, `--mixed`, and `--hard`

### `git reset --soft`

* Moves the HEAD pointer to a previous commit.
* Keeps changes in the staging area.
* Working directory remains unchanged.

### `git reset --mixed`

* Moves the HEAD pointer to a previous commit.
* Unstages the changes.
* Keeps the changes in the working directory.
* This is the default reset mode.

### `git reset --hard`

* Moves the HEAD pointer to a previous commit.
* Removes changes from the staging area.
* Removes changes from the working directory.

---

## 2. Which one is destructive and why?

`git reset --hard` is destructive because it permanently discards uncommitted changes from both the staging area and the working directory. Recovering those changes may not always be possible.

---

## 3. When would you use each one?

### `--soft`

Use when you want to rewrite or combine commits while keeping all changes staged.

### `--mixed`

Use when you want to modify what will be included in the next commit by unstaging changes.

### `--hard`

Use when you want to completely discard unwanted local commits and changes.

---

## 4. Should you ever use `git reset` on commits that are already pushed?

Generally, no. Resetting pushed commits rewrites commit history and can cause problems for collaborators who have already pulled those commits. If changes need to be undone in a shared repository, `git revert` is usually the safer option.

######

# Day 25 Notes – Git Revert

## 1. How is `git revert` different from `git reset`?

### `git revert`

* Creates a new commit that undoes changes from a previous commit.
* Preserves the existing commit history.
* Safe to use on shared branches.

### `git reset`

* Moves the branch pointer to an earlier commit.
* Can remove commits from the current branch history.
* May rewrite commit history.

---

## 2. Why is revert considered safer than reset for shared branches?

`git revert` does not rewrite history. Instead, it records the reversal as a new commit. Since existing commits remain unchanged, other team members are not affected.

`git reset` changes commit history, which can create conflicts and confusion if those commits have already been pushed and pulled by others.

---

## 3. When would you use revert vs reset?

### Use `git revert` when:

* Working on shared branches like `main`.
* The commits have already been pushed.
* You want a clear audit trail showing what was undone.

### Use `git reset` when:

* Working on local branches.
* Cleaning up recent commits before pushing.
* Reorganizing commit history during development.

---

## Observation from Hands-On

After reverting Commit Y:

* Commit Y remained visible in `git log`.
* A new commit named `Revert "Commit Y"` was created.
* The changes introduced by Commit Y were undone without deleting history.


