#!/usr/bin/perl

package LEAPS;

use Digest::SHA1 qw();
use YAML::Syck qw(DumpFile);
use JSON::XS qw(encode_json);


if ($0 eq __FILE__) {
 my $ntp_offset = 2287785600-78793200;
 printf "--- # %s\n",$0;
 my $file = shift;
 my ($mod_date,$exp_date,$last_date,$deltas,$sha1) = &loadLeaps($file);
 printf "mod_date: %u -- MJD: %.1f; %s\n",$mod_date,mjdNumber($mod_date),ntpDate($mod_date);
 printf "exp_date: %u -- MJD: %.1f; %s\n",$exp_date,mjdNumber($exp_date),ntpDate($exp_date);
 use YAML::XS qw(Dump);
 my $data = &dataLeaps($deltas);
 &txtLeaps('src/leap-seconds.dat',$mod_date,$exp_date,$deltas);
 &txtLeaps('src/leap-seconds.list',$mod_date,$exp_date,$deltas);
 &csvLeaps('src/leap-seconds.csv',$mod_date,$exp_date,$deltas);
 &csvLeaps('src/leap-seconds.json',$mod_date,$exp_date,$deltas);
 &csvLeaps('src/leap-seconds.js',$mod_date,$exp_date,$deltas);

 &txtLeaps('src/leap-seconds-list.dat',$last_date,$exp_date,$deltas);
 &txtLeaps('src/leap-seconds-list.txt',$last_date,$exp_date,$deltas);
 &ymlLeaps('src/leap-seconds-list.yml',$last_date,$exp_date,$deltas);
 &jsonLeaps('src/leap-seconds-list.json',$last_date,$exp_date,$deltas);
 &jsLeaps('src/leap-seconds-list.js',$last_date,$exp_date,$deltas);

 my $now_date = sprintf'%u',$^T + $ntp_offset;
 &txtLeaps('src/leap-seconds-now.dat',$now_date,$exp_date,$deltas);
 &txtLeaps('src/leap-seconds-now.txt',$last_date,$exp_date,$deltas);

 &nxtLeaps('src/leap-seconds-skip.txt',$exp_date,$deltas,0);
 &nxtLeaps('src/leap-seconds-add.txt',$exp_date,$deltas,1);
 &nxtLeaps('src/leap-seconds-skip.dat',$exp_date,$deltas,0);
 &nxtLeaps('src/leap-seconds-add.dat',$exp_date,$deltas,1);

 printf "data: %s\n",$data;
 my $digest = hashLeaps($mod_date,$exp_date,$data);
 printf "sha1:   %s\n",$sha1;
 printf "digest: %s\n",$digest;
 my $last_hash = hashLeaps($last_date,$exp_date,$data);
 printf "last_hash: %s\n",$last_hash;
 my $now_hash = hashLeaps($now_date,$exp_date,$data);
 printf "now_hash: %s\n",$now_hash;
 exit $?;
}

sub ymlLeaps {
  my ($file,$mod,$exp,$deltas) = @_;
  my $data = &dataLeaps($deltas);
  my $sha1 = hashLeaps($mod,$exp,$data);
  my $hash = join' ',map { sprintf'%x',$_ } unpack'N*',pack'H*',$sha1;
  my $last_leap = $deltas->[-1][0];
  my $last_delta = $deltas->[-1][1];
  my $yml = {
    url => "http://127.0.0.1:8080/ipfs/f01551114$sha1",
    sha1 => $sha1,
    data => "$data",
    last_delta => $last_delta,
    last_leap => $last_leap,
    leap_seconds => [ map { { timestamp => $_->[0], offset => $_->[1]}; } @{$deltas} ],
    last_updated => $mod,
    expiration_date => $exp,
    hash => "$hash"};
  DumpFile($file,$yml);
  return $yml;
}
sub jsonLeaps {
  my ($file,$mod,$exp,$deltas) = @_;
  my $data = &dataLeaps($deltas);
  my $sha1 = hashLeaps($mod,$exp,$data);
  my $hash = join' ',map { sprintf'%x',$_ } unpack'N*',pack'H*',$sha1;
  my $last_leap = $deltas->[-1][0];
  my $last_delta = $deltas->[-1][1];
  my $yml = {
    url => "http://127.0.0.1:8080/ipfs/f01551114$sha1",
    sha1 => $sha1,
    data => "$data",
    last_delta => $last_delta,
    last_leap => $last_leap,
    leap_seconds => [ map { { timestamp => $_->[0], offset => $_->[1]}; } @{$deltas} ],
    last_updated => $mod,
    expiration_date => $exp,
    hash => "$hash"};
  my $json = encode_json($yml);
  open F,'>',$file or warn $!; print F $json; close F;
  return $json;
}
sub jsLeaps {
  my ($file,$mod,$exp,$deltas) = @_;
  my $data = &dataLeaps($deltas);
  my $sha1 = hashLeaps($mod,$exp,$data);
  my $hash = join' ',map { sprintf'%x',$_ } unpack'N*',pack'H*',$sha1;
  my $last_leap = $deltas->[-1][0];
  my $last_delta = $deltas->[-1][1];
  my $yml = {
    url => "http://127.0.0.1:8080/ipfs/f01551114$sha1",
    sha1 => $sha1,
    data => "$data",
    last_delta => $last_delta,
    last_leap => $last_leap,
    leap_seconds => [ map { { timestamp => $_->[0], offset => $_->[1]}; } @{$deltas} ],
    last_updated => $mod,
    expiration_date => $exp,
    hash => "$hash"};
  my $json = encode_json($yml);
  open F,'>',$file or warn $!;
  printf F "/* Javascript file for leap-seconds.list (%s) */\n",$mod;
  printf F "window.leapSeconds = %s;\n",$json;
  printf F "window.leapSecondsDelta = '%s';\n",$last_delta;
  printf F "window.leapSecondsData = '%s';\n",$data;
  printf F "window.leapSecondsHash = '%s';\n",$sha1;
  close F;
  return $json;
}

sub csvLeaps {
  my ($file,$mod,$exp,$deltas) = @_;
  my $data = &dataLeaps($deltas);
  my $sha1 = hashLeaps($mod,$exp,$data);
  open F,'>',$file or warn $!;
  printf F "# csv file for leaps seconds until %s\n",ntpDate($exp);
  printf F "#\$ %s # MJD: %s, modified on %s\n",$mod,mjdNumber($mod),ntpDate($mod);
  printf F "#\@ %s # MJD: %s, expires on %s\n",$exp,mjdNumber($exp),ntpDate($exp);
  printf F "# sha1: %s\n",$sha1;
  print  F "NTP Time, DTAI, MJD, UT1 Date\n";
  foreach (@{$deltas}) {
   my $ntpd = $_->[0];
   my $dut = $_->[1];
   printf F "%u,%d,%.1f,%s\n",$ntpd,$dut,mjdNumber($ntpd),ntpDate($ntpd+$dut);
  }
  my @hash = unpack'N*',pack'H*',$sha1;
  printf F "# expires on %s (%u)\n",ntpDate($exp),$exp;
  printf F "#h %s\n",join' ',map { sprintf'%x',$_ } @hash;
  close F;
  return $sha1;
}
sub txtLeaps {
  my ($file,$mod,$exp,$deltas) = @_;
  my $data = &dataLeaps($deltas);
  my $sha1 = hashLeaps($mod,$exp,$data);
  open F,'>',$file or warn $!;
  if ($file =~ m/\.data?$/) {
    printf F "%s%s%s",$mod,$exp,$data;
  } else {
     printf F "# file: leaps-seconds.list valid until %s\n",ntpDate($exp);
     printf F "#\$ %s # MJD: %s, modified on %s\n",$mod,mjdNumber($mod),ntpDate($mod);
     printf F "#\@ %s # MJD: %s, expires on %s\n",$exp,mjdNumber($exp),ntpDate($exp);
     printf F "# sha1: %s\n",$sha1;
     print  F "# NTP Time\tDTAI # MJD, UT1 Date\n";
     foreach (@{$deltas}) {
        my $ntpd = $_->[0];
        my $dut = $_->[1];
        printf F "%u\t%d # %.1f %s\n",$ntpd,$dut,mjdNumber($ntpd),ntpDate($ntpd+$dut);
     }
     my @hash = unpack'N*',pack'H*',$sha1;
     printf F "# expires on %s (%u)\n",ntpDate($exp),$exp;
     printf F "#h %s\n",join' ',map { sprintf'%x',$_ } @hash;
  }
  close F;
  return $sha1;
}

sub nxtLeaps { # file,exp_date,deltas,0;
 my $_days = 3600 * 24;
 my $ntp_offset = 2287785600-78793200;
 my ($file,$exp,$deltas,$lsec) = @_;
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($exp - $ntp_offset + 4 * $_days + 3601);
 printf "exp: %s\n",ntpDate($exp);
 my $tic = $exp - $ntp_offset + 4 * $_days + 3601;
 printf "jan: %s\n",sortableDate($tic);
 printf "mon: %s\n",$mon;
 my $mod = $exp;
 my $_6mon = 6 * 30.5 * $_days;
 if ($mon == 0) {
   if (isLeapYear($year+1900)) {
     $_6mon -= $_days;
   } else {
      $_6mon -= 2 * $_days;
   }
   $last = $exp + $_6mon + 4 * $_days;
   $exp = $exp + $_6mon + 3 * $_days
 } else {
   $last = $exp + $_6mon + 2 * $_days;
   $exp = $exp + $_6mon - $_days
 }

 my $dut = $deltas->[-1][1] + 1;
 if ($lsec == 1) {
   push @{$deltas}, [$last,$dut]; # add a leap-second
 }
 my $data = &dataLeaps($deltas);
 my $sha1 = hashLeaps($mod,$exp,$data);
  open F,'>',$file or warn $!;
  if ($file =~ m/\.data?$/) {
    printf F "%s%s%s",$mod,$exp,$data;
  } else {
     printf F "# file: leaps-seconds.list valid until %s\n",ntpDate($exp);
     printf F "#\$ %s # MJD: %s, modified on %s\n",$mod,mjdNumber($mod),ntpDate($mod);
     printf F "#\@ %s # MJD: %s, expires on %s\n",$exp,mjdNumber($exp),ntpDate($exp);
     printf F "# sha1: %s\n",$sha1;
     print  F "# NTP Time\tDTAI # MJD, UT1 Date\n";
     foreach (@{$deltas}) {
        my $ntpd = $_->[0];
        my $dut = $_->[1];
        printf F "%u\t%d # %.1f %s\n",$ntpd,$dut,mjdNumber($ntpd),ntpDate($ntpd+$dut);
     }
     my @hash = unpack'N*',pack'H*',$sha1;
     printf F "# expires on %s (%u)\n",ntpDate($exp),$exp;
     printf F "#h %s\n",join' ',map { sprintf'%x',$_ } @hash;
  }
  close F;
  return $sha1;

}

sub isLeapYear
{
   my $year = shift;
   return 0 if $year % 4;
   return 1 if $year % 100;
   return 0 if $year % 400;
   return 1;
}



sub loadLeaps {
  my $leapsf = shift;
  my $table;
  my $modified_on;
  my $expires_on;
  my $last_on;
  my $hash;
  local *F; open F,'<',$leapsf or warn "$!";
  while (<F>) {
     chomp;
     if (m/^#\$/) {
        $modified_on = (split(/[ \t]+/))[1];
     } elsif (m/^#@/) {
        $expires_on = (split(/[ \t]+/))[1];
     } elsif (! m/^#/) {
        my ($ntp_stamp,$dut) = split(/[ \t]+/);
        push @{$table}, [$ntp_stamp,$dut];
        $last_on = $ntp_stamp;
     } elsif (m/^#h/) {
        my (undef,@nybs) = split(/[ \t]+/);
        $hash = join'',map { substr('0'x8 . $_,-8); } @nybs;
     }
  }
  close F;
  return ($modified_on,$expires_on,$last_on,$table,$hash);
}
sub dataLeaps {
 my $d = '';
 for (@{$_[0]}) {
   $d .= $_->[0].$_->[1];
 }
 return $d;
}

sub hashLeaps {
 my ($mod,$exp,$data) = @_;
 my $msg = Digest::SHA1->new();
    $msg->add($mod);
    $msg->add($exp);
    $msg->add($data);
 # for (@{$deltas}) {
 #    $msg->add($_->[0]);
 #    $msg->add($_->[1]);
 # }
 return $msg->hexdigest();
}

sub mjdNumber { # Modified Julian Day Number
 return $_[0] / 86400 + 15020;
}
sub ntpDate {
  # NTP timestamp 1 July 1972
  my $ntp_offset = 2287785600-78793200;
  my $ntic = shift;
  return sortableDate($ntic - $ntp_offset);
}

sub sortableDate { # return a human readable date ... but still sortable ...
  my $tic = int ($_[0]);
  my $ms = ($_[0] - $tic) * 1000;
     $ms = ($ms) ? sprintf('%04u',$ms) : '____';
  my ($sec,$min,$hour,$mday,$mon,$yy) = (localtime($tic))[0..5];
  my ($yr4,$yr2) =($yy+1900,$yy%100);
  my $date = sprintf '%04u-%02u-%02u %02u.%02u.%02u',
             $yr4,$mon+1,$mday, $hour,$min,$sec;
  return $date;
}

1; # $Source: /my/perl/scripts/mkleaps.pl$
