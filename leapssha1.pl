#!/usr/bin/perl

# intent: verify a leap-seconds.list file

use Digest::SHA1 qw();

my $msg = Digest::SHA1->new();

printf "--- # %s\n",$0;
my $sha1;
while (<>) {
  chomp;
  if (m/^#\$/) { 
    $update = (split(/[ \t]+/))[1];
    printf "update: %u -- MJD: %.1f; %s\n",$update,MJD($update),NTPdate($update);
    $msg->add($update);
  } elsif (m/^#@/) {
    $expire = (split(/[ \t]+/))[1];
    printf "expire: %u -- MJF: %.1f; %s\n",$expire,MJD($expire),NTPdate($expire);
    $msg->add("$expire");
  } elsif (! m/^#/) {
    ($date,$dut) = split(/[ \t]+/);
    printf "dut: %u # ntp: %u -- MJD: %.1f %s\n",$dut,$date,MJD($date+$dut),NTPdate($date+$dut);
    $msg->add("$date");
    $msg->add("$dut");
  } elsif (m/^#h/) {
    my (undef,@nybs) = split(/[ \t]+/);
    $sha1 = join'',map { substr('0'x8 . $_,-8); } @nybs;
    printf "sha1:   %s\n",$sha1;
  }
}

my $digest = $msg->hexdigest();
printf "digest: %s\n",$digest;
die sprintf"error: digest != %s",$sha1 if ($digest ne $sha1);

print "...\n";

exit $?;

sub MJD { # Modified Julian Day Number
 return $_[0] / 86400 + 15020;
}
sub NTPdate {
  # NTP timestamp 1 July 1972
  my $ntp_offset = 2287785600-78793200;
  my $ntic = shift;
  return sdate($ntic - $ntp_offset);
}

sub sdate { # return a human readable date ... but still sortable ...
  my $tic = int ($_[0]);
  my $ms = ($_[0] - $tic) * 1000;
     $ms = ($ms) ? sprintf('%04u',$ms) : '____';
  my ($sec,$min,$hour,$mday,$mon,$yy) = (localtime($tic))[0..5];
  my ($yr4,$yr2) =($yy+1900,$yy%100);
  my $date = sprintf '%04u-%02u-%02u %02u.%02u.%02u',
             $yr4,$mon+1,$mday, $hour,$min,$sec;
  return $date;
}

1; # $Source: /my/perl/scripts/leapssha1.pl$
