#!/usr/bin/perl  
################################################################################
# Program : def2dp.pl
# Desc    : 
# Usage : def2dp.pl xxx.001 [outputDir]
#         default outputDir is ./tmp
# Written BY Nil 2006/10/20 
################################################################################
$DEBUG   = 0;

## string processing utility
sub trim($) {
  $_ = shift;
  s/^\s*//;
  s/\s*$//;
  return $_;
}

## unique array values via a hash with sort
sub uniq(@) { @_{@_} = 1; sort keys %_ ; }


## writting lines into log file 
sub logger(@) {
	while($_ = shift) {
  	$fileOut = ">>" . $logFile ;
  	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time());
    open(LOGT, $fileOut) || print "Failed to open log file \n";
    printf LOGT "%4s-%2s-%2s %s:%s:%s %s" ,$YEAR,$MONTH,$DAY,$hour,$min,$sec ,$_;
    print;
    close(LOGT);
  }
}
sub logFileLists(@) {
	while($_ = shift) {
  	$fileOut = ">>" . $logFileLists ;
  	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time());
    open(LOGLT,$fileOut) || print "Failed to open log file \n";
    printf LOGLT "%4d-%2d-%2d %s:%s:%s %s\n" ,$YEAR,$MONTH,$DAY,$hour,$min,$sec ,$_;
    close(LOGLT);
  }
}

## debugger
sub debugger(@) {
  if ($DEBUG) {
  	while($_ = shift) {
      print;
    }
  }
}

## sqlplus like DBI, Thanks for PDF dragon...
#---------
# initialize $dbName, $dbUser, $dbPass first
sub fetchrow_array {
    my $line;
    my @row;
    my $ref_lines=$_[0];
    $line = shift (@$ref_lines);
    return if !($line);
    $line =~ s/^\s+//g;
    $line =~ s/\s+$//g;
    $line =~ s/\s+\|~\|/\|~\|/g;
    $line =~ s/\|~\|\s+/\|~\|/g;
    @row = split(/\|~\|/,$line);
    return @row;
}
sub execute_sql {
    my $sql= shift; my @param = @_;
    for $p (@param) { $sql =~ s/[\?]/$p/s; }
    my $s = qx{sqlplus -s $dbUser/$dbPass\@$dbName <<EOF
    SET NEWPAGE 0 SPACE 0 TRIMSPOOL ON TRIMOUT ON LINESIZE 1024 PAGESIZE 0 VERIFY OFF ECHO OFF FEEDBACK OFF HEADING OFF TERMOUT OFF colsep |~|
    $sql;
    exit
    EOF};
    $s =~ s/^\nSession altered.\n\n//;
    my @lines = split (/\n/,$s);
    return @lines;
}

# ---------------
#  initialize ..
# ---------------
use FileHandle;
use File::Basename;

$PROGRAM  = ($0 =~ /^([^\.]+)/)?$1:$0;
$HOME     = $ENV{"HOME" }; 

# ---------------
#  prepare 4 log
# ---------------
$FILE = shift || die "Please specified file to parsing...\n";
$toDir = shift || ($toDir = "./tmp");
$toDir =~ s:/*$::;

# generate filename for log
($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time());
$YEAR  = ($year+1900);
$MONTH = ($mon+1 <10)?('0'.($mon+1)):($mon+1);
$DAY   = ($mday  <10)?('0'. ($mday)):($mday);

# initialize logger
$logFile      = "../log/$PROGRAM\_".$YEAR.$MONTH.$DAY.".log";
$logFileLists = "../log/$PROGRAM\_".$YEAR.$MONTH.$DAY.".lst";
logger "\nProcess file ==>".$FILE."\n";

################################################################################
# -------------------------------
# open file, get header lot info
# -------------------------------
open(FILE) || die "Cannot open file[$FILE].\n";
open(OUT, "> $toDir/$FILE") || die "Cannot open output file[$OUT].\n";
eval {
  my (@lines) = <FILE>;
  # -------------
  # config area
  # -------------
  $dbName = $dbUser = $dbPass = "xxx";
  $sqlCmd = qq/ 
  select iwi.defect_id, iwi.image_filespec, iwi.image_id
	from insp_wafer_summary iws,
	     insp_defect id, 
	     insp_wafer_image iwi
	where
     iwi.wafer_key = id.wafer_key and
     iwi.inspection_time = id.inspection_time and
     iwi.defect_id = id.defect_id and
     iws.wafer_key = id.wafer_key and
     iws.inspection_time = id.inspection_time and
     iws.lot_id = '?' and
     iws.wafer_id = '?' and
     iws.layer_id = '?' and
	 iws.inspection_time = to_date('?', 'MM-DD-YY HH24:MI:SS')
  /;
  %target = (
    LotID => qq/"(.+)"/, StepID => qq/"(.+)"/,  WaferID=> qq/"(.+)"/,  
    ResultTimestamp => "([0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9])",
  );
  @eliminate = (Tiff);
  # ---------------
  # start to rock!
  # ---------------
  for $t (keys %target) {
    ($line) = grep /^$t/, @lines;
    $$t = $1 if $line =~ m<$target{$t}>;
  }
  for $e (@eliminate) { @lines = grep !/^$e/, @lines };
  $lastLine = pop @lines;
  @resultSet = execute_sql($sqlCmd, $LotID, $WaferID, $StepID, $ResultTimestamp);
  while(($DefectID, $ImagePath, $ImageID) = fetchrow_array(\@resultSet)) {
    ($ImageDir = $1, $ImageFile = $2) if ($ImagePath =~ m:(.+)/([^/]+)$:);
    push @insertLines, " $DefectID $ImageDir $ImageFile $ImageID\n";
  }
  if (defined @insertLines) {
    unshift @insertLines, "ImageList\n";
    $insertLines[$#insertLines] =~ s/(.+)/$1;/;
    push @lines, @insertLines;
  }
  push @lines, $lastLine;
  print OUT foreach (@lines);
  
  logger "[$LotID], [$StepID], [$WaferID], [$ResultTimestamp]\n";
  logFileLists($FILE);
};


if($@) {
ERROR:
  close(OUT) if (defined OUT);
  close(FILE) if (defined FILE);
  warn "Transcation rollback and aborted.\n".$@."\n";
  logger "Transcation rollback and aborted.\n".$@."\n";
  exit(1);
}

close(OUT) if (defined OUT);
close(FILE) if (defined FILE);

exit;
    
    
=begin comment
# -----------------
#  Deprecated code
# -----------------
logger (("-" x 60)."\n");

=cut off comment