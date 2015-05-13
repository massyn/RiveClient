#!/usr/bin/perl

use strict;
use Getopt::Std;
use RiveScript;

use Win32::OLE;
my $v=Win32::OLE->new('SAPI.SpVoice');

print <<TOP;
RiveScript Interpreter Version 1.0
Written by Phil Massyn (2015)
www.massyn.net
=============================================
TOP
;
# Read the command line parameters
my %opts;
getopts('i:s', \%opts);

print "\n";

my $s = $opts{s};

# Get the input directory
my $inputdir = $opts{i};

if($inputdir eq '')
{
	print STDERR "defaulting -i (input directory) = bot\n";
	$inputdir = 'bot';
}

if($s eq '')
{
	print STDERR "defaulting -s (text to speech) = <blank>\n";
}

if(!-d $inputdir)
{
	die("Input directory \'$inputdir\' does not exist");
}

my $rs = RiveScript->new();
$rs->loadDirectory($inputdir);
$rs->sortReplies();

my $botname = $rs->{bot}->{botname} . $rs->{bot}->{name};

if($botname eq '')
{
	$botname = "RESPONSE";
}
# setup the user interface
my $input = '';

my $session = time;

# Ready to chat

my $response = $rs->reply($session,'CONNECT');
print "$botname> $response\n\n";
if($opts{s} == 1)
{
	&talk($response);
}

while($input !~ /^bye$/i)
{
	print "USER> ";
	$input = <STDIN>;
	chomp($input);

	if($input)
	{
		my $response = $rs->reply($session,$input);
		print "$botname> " . $response . "\n\n";
		&logger($inputdir,$session,$botname,$input,$response,);

		if($opts{s} == 1)
		{
			&talk($response);
		}
	}
}

exit(0);

sub logger
{
	my ($inputdir,$session,$botname,$input,$response) = @_;

	# Get the current time stamp
	my $time = time;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($time);
	$year += 1900;
	$mon++;
	my $dte = sprintf("%4d.%02d.%02d",$year,$mon,$mday);
	my $tme = sprintf("%d:%02d:%02d",$hour,$min,$sec);

	# Remove ; (since it's our delimiter)
	$session =~ s/\;//g;
	$input =~ s/\;//g;
	$response =~ s/\;//g;

	# Append it to the log file
	open(OUT,">>$inputdir/chat.log");
	print OUT "$dte $tme;$time;$0;$session;$botname;$input;$response\n";
	close OUT;
}

sub talk
{
	my ($in) = @_;
    	$v->Speak($in);	
    	$v->waituntildone(-1);	

#	`echo "$in" | festival --tts --pipe 2>&1`;	# <!-- LINUX -->
}
