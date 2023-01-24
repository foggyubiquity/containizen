{
  callPackage,
  rsync,
  s-tar,
  s6-overlay-noarch,
  s6-overlay-x86_64,
  tree
}:
let
  s6-services = ../s6;
  start = builtins.readFile ./auto-start-language;
in
''
  # User Permissions
  mkdir -p ./opt/app ./root ./home/containizen ./etc ./var ./tmp/log ./run
  ln -s /tmp/log ./var/log
  echo "root:x:0:0::/root:/bin/s6-false" > ./etc/passwd
  echo "containizen:x:289:308::/home/containizen:/bin/s6-false" >> ./etc/passwd
  echo "root:!x:::::::" > ./etc/shadow
  echo "containizen:!:18226::::::" >> ./etc/shadow
  echo "root:x:0:" > ./etc/group
  echo "containizen:x:308:" >> ./etc/group
  echo "root:x::" > ./etc/gshadow
  echo "containizen:!::" >> ./etc/gshadow

  ${rsync}/bin/rsync -a ${s6-services}/ ./
  # s6-services affects permissions necessary for s6-overlay-noarch
  chmod -R 777 .
  ${s-tar}/bin/star -x -xz -nochown -f=${s6-overlay-noarch} -C=./
  # symbolic link /bin (nixpkgs style) to /command (s6-overlay style)
  # cd command
  # ln -s ../bin/* .
  # cd ..
  chmod -R 0755 .

  # create must exist directories
  mkdir -p ./etc/s6/init/env-stage2
  mkdir -p ./etc/{cont-init.d,cont-finish.d,fix-attrs.d,services.d}

  # create "supervise" directory in fdholder, its needed for no-catchall
  # stage2 wake up
  mkdir -p ./etc/s6/services/s6-fdholderd/supervise
  chmod 0700 ./etc/s6/services/s6-fdholderd/supervise

  # fix perms for utilities
  # chmod 0550 ./usr/bin/fix-attrs
  # chmod 0550 ./usr/bin/logutil-{newfifo,service,service-main}
  # chmod 0550 ./usr/bin/printcontenv
  # chmod 0550 ./usr/bin/with-{contenv,retries}
  # chmod 0550 ./usr/bin
  # just-containers/s6-overlay V3 change
  # https://github.com/just-containers/s6-overlay/blob/master/MOVING-TO-V3.md
  chmod 0550 ./command

  # fix init perms
  chmod 0550 ./init
  chmod 0550 ./etc/s6/init
  # chmod 0550 ./etc/s6/init-catchall/init-*
  # chmod 0550 ./etc/s6/init-no-catchall/init-*
  # chmod 0550 ./etc/s6/services/.s6-svscan/{crash,finish}
  # chmod 0550 ./etc/s6/services/s6-fdholderd/run
  # chmod 0550 ./etc/s6/services/s6-svscan-log/run

  # fix custom file permissions
  chmod 0540 ./etc/fix-attrs.d/00-boot
  chmod 0540 ./etc/cont-init.d/00-boot

  # fix /tmp permissions
  chmod -R 0777 ./tmp

  # /start app auto launcher
  cat > ./start <<EOF
  ${start}
  EOF
  chmod 0550 ./start
''
