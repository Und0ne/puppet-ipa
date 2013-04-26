define ipa::replicainstall (
  $host = $name,
  $adminpw = {},
  $dspw = {}
) {

  $file = "/var/lib/ipa/replica-info-${host}.gpg"

  Exec["replicainfocheck-${host}"] ~> Exec["clientuninstall-${host}"] ~> Exec["replicainstall-${host}"] ~> Exec["removereplicainfo-${host}"]

  exec {
    "replicainfocheck-${host}":
      command   => "/usr/bin/test -e ${file}",
      tries     => '60',
      try_sleep => '60',
      unless    => "/usr/sbin/ipactl status >/dev/null 2>&1";

    "clientuninstall-${host}":
      command   => "/usr/sbin/ipa-client-install --uninstall --unattended",
      refreshonly => true;

    "replicainstall-${host}":
      command   => "/usr/sbin/ipa-replica-install --admin-password=${adminpw} --password=${dspw} --skip-conncheck --unattended ${file}",
      timeout   => '0',
      refreshonly => true;

    "removereplicainfo-${host}":
      command     => "/bin/rm -f ${file}",
      refreshonly => true,
  }<- notify { "Running IPA replica install, please wait.": }
}