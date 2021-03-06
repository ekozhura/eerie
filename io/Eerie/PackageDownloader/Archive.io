ArchiveDownloader := Eerie PackageDownloader clone do(
  formats := Object clone do(
    doRelativeFile("archives/targz.io")
    doRelativeFile("archives/tarbz2.io")
    doRelativeFile("archives/7zip.io")
    doRelativeFile("archives/zip.io")
    doRelativeFile("archives/rar.io")
  )

  whichFormat := method(uri_,
    self formats slotNames foreach(name,
      self formats getSlot(name) extensions foreach(ext,
        uri_ containsSeq("." .. ext) ifTrue(
          return(name))))

    nil)

  canDownload := method(uri_,
    self whichFormat(uri_) != nil)

  download := method(
    self format := self formats getSlot(self whichFormat(self uri))
    tmpFile := nil
    
    self uri containsSeq("http") ifTrue(
      tmpFile = Directory with(Eerie tmpDir) fileNamed(self uri split("/") last)
      URL with(self uri) fetchToFile(tmpFile)
      tmpFile exists ifFalse(
        Eerie FailedDownloadException raise(self uri))
      self uri = tmpFile path)

    Eerie sh(self format cmd interpolate)

    # If archive contains an directory with all the code we need to move
    # everything out of there
    (self root directories size == 1 and self root files isEmpty) ifTrue(
      extraDir := self root directories first name
      Eerie sh("mv #{extraDir} __contents__" interpolate, true, self path)
      Eerie sh("mv __contents__/* ." interpolate, true, self path)
      Eerie sh("rm -rf __contents__", true, self path))

    tmpFile ?remove
    true)

  hasUpdates := method(
    false)
)
