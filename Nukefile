;; source files
(set @m_files     (filelist "^objc/.*.m$"))

(set @arch (list "x86_64"))
(set @cc "clang")
(set @cflags "-fobjc-arc")
(set @ldflags "-framework Foundation -framework AudioToolbox -framework AudioUnit -framework Accelerate")

;; framework description
(set @framework "RadAudio")
(set @framework_identifier "com.radtastical.radaudio")
(set @framework_creator_code "????")

(compilation-tasks)
(framework-tasks)

(task "clobber" => "clean" is
      (SH "rm -rf #{@framework_dir}"))

(task "default" => "framework")

(task "doc" is (SH "nudoc"))

