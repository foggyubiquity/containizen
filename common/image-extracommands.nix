{ rsync, callPackage }:
let
  s6-overlay = callPackage ../pkgs/s6-overlay.nix {};
  s6-services = ../s6;
  start = builtins.readFile ../auto-start-language;
in
''
  # User Permissions
  mkdir -p ./opt/app ./root ./home/containizen ./etc ./var ./tmp/log
  ln -s /tmp/log ./var/log
  chmod 755 ./etc ./opt/app ./root ./home/containizen
  echo "root:x:0:0::/root:/bin/s6-false" > ./etc/passwd
  echo "containizen:x:289:308::/home/containizen:/bin/s6-false" >> ./etc/passwd
  echo "root:!x:::::::" > ./etc/shadow
  echo "containizen:!:18226::::::" >> ./etc/shadow
  echo "root:x:0:" > ./etc/group
  echo "containizen:x:308:" >> ./etc/group
  echo "root:x::" > ./etc/gshadow
  echo "containizen:!::" >> ./etc/gshadow

  chmod 0555 ./etc/passwd ./etc/shadow ./etc/group ./etc/gshadow

  ${rsync}/bin/rsync -a ${s6-services}/ ./
  ${rsync}/bin/rsync -a ${s6-overlay}/builder/overlay-rootfs/. .
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
  chmod 0550 ./usr/bin

  # fix init perms
  chmod 0550 ./init
  chmod 0550 ./etc/s6/init/init-*
  chmod 0550 ./etc/s6/init-catchall/init-*
  chmod 0550 ./etc/s6/init-no-catchall/init-*
  chmod 0550 ./etc/s6/services/.s6-svscan/{crash,finish}
  chmod 0550 ./etc/s6/services/s6-fdholderd/run
  chmod 0550 ./etc/s6/services/s6-svscan-log/run

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
