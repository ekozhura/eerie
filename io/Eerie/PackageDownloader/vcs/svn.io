svn := Object clone do(
    check := method(uri,
        if(uri containsSeq("git://") or uri containsSeq(".git"), return false)
        r := System runCommand("svn info " .. uri)
        r exitStatus == 0 and r stderr containsSeq("Not a valid") not
    )

    cmd         := "svn"
    download    := list("co #{self uri} #{self path}")
    update      := list("up")

    hasUpdates  := method(path,
        # svn status reference http://svnbook.red-bean.com/en/1.2/svn.ref.svn.c.status.html

        r := System runCommand("svn status --show-updates " .. path)
        changed := r stdout split("\n")
        changed removeLast
        changed = changed select(containsSeq("*")) map(split(" ") last)

        Eerie log("SVN repo changes (#{path}):", "debug")
        Eerie log("Changed files: " .. (changed join(", ")), "debug")

        changed isEmpty not
    )
)
