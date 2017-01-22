#!/usr/bin/perl  
################################################################################
# Program : WAT2DP.pl
# Desc    : 
# Usage : WAT2DP.pl xxx.wat?
# Written BY Nil 2006/09/01 
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
    open(LOGT, $fileOut) || die "Failed to open log file \n";
    printf LOGT "%4s-%2s-%2s %s:%s:%s %s" ,$YEAR,$MONTH,$DAY,$hour,$min,$sec ,$_;
    print;
    close(LOGT);
  }
}
sub logFileLists(@) {
	while($_ = shift) {
  	$fileOut = ">>" . $logFileLists ;
  	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time());
    open(LOGLT,$fileOut) || die "Failed to open log file \n";
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

## check parameter
sub getParameter() {
  my $line, $pn, $lcl,ucl,$lsl,$usl;
  my $exLow, $exHigh, $criticalFlag, $lsl, $usl;
  open(LIMIT, $limitFile) || die( "ERROR: Can't open LimitFile=($limitFile)\n");
  debugger "Limit file is [$limitFile]\n";
  
  while(!eof(LIMIT)) {
    # get line and do some pre-processing
    $line = <LIMIT>;
    chomp($line);
    $line =~ s/\^M//g; 
    next if (trim($line) eq '');
    
    # get parameter name
    $pn = substr($line,  6, 11);
    $pc = substr($line, 17, 11);
    $pn = trim $pn;
    $pc = trim $pc;
    $p = "$pn $pc";
    $p  = trim $p;
    $p =~ s/\s+/_/g;
    debugger "[$pn], [$pc], [$p]\n";

    # get Spec.
    $spec = trim(substr($line, 27));
    ($param{"$p"}{'exLow'}, 
     $param{"$p"}{'exHigh'}, 
     $param{"$p"}{'criticalFlag'}, 
     $param{"$p"}{'lsl'}, 
     $param{"$p"}{'usl'}
    ) = split(/\s+/, $spec);
    ($param{"$p"}{'name'}, $param{"$p"}{'cl'}) = ($pn, $pc);
    push @parameters, $p;
  }
  close(LIMIT);
}

# ---------------
#  initialize ..
# ---------------
use FileHandle;
use File::Basename;

$PROGRAM  = $0;
$HOME     = $ENV{"HOME" }; 
$WATDIR   = $HOME."/md42/WAT";
$LIMITDIR = $WATDIR."/limit";
$paramPerPage = 10;

@data = ();
@param = ();
@parameters = ();

# ----------------
#  output format
# ----------------
$lotInfo = q/
format WAT = 
                                                  W.A.T. DATA ATTACHED                           
 TYPE NO :@<<<<<<<<<<<<<                PROCESS  :@<<<<<<<<<<<<                 PCM SPEC:@<<<<<<<<<<   QTY:@< pcs
          $product                                $process                               $program          $waferCount
 LOT ID  :@<<<<<<<<<<<<<                DATE     :@<<<<<<<<<<<<
          $lot                                    $date
.
/;
$header  = q/
format WAT = 
 WAF SITE    @<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<
             $p[0]       $p[1]       $p[2]       $p[3]       $p[4]       $p[5]       $p[6]       $p[7]       $p[8]       $p[9] 
 ID  ID      @<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<
             $c[0]       $c[1]       $c[2]       $c[3]       $c[4]       $c[5]       $c[6]       $c[7]       $c[8]       $c[9] 
.
/;
$body    = q/
format WAT =
 @<<-@<<     @<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<
 $w  $s      $v[0]       $v[1]       $v[2]       $v[3]       $v[4]       $v[5]       $v[6]       $v[7]       $v[8]       $v[9]       
.
/;
$footer  = q/
format WAT =
 -------------------------------------------------------------------------------------------------------------------------------
 AVERAGE     0           0           0           0           0           0           0           0           0           0     
 STD DEV     0           0           0           0           0           0           0           0           0           0     
 SPEC HI     @<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<
             $usl[0]     $usl[1]     $usl[2]     $usl[3]     $usl[4]     $usl[5]     $usl[6]     $usl[7]     $usl[8]     $usl[9]     
 SPEC LO     @<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<@<<<<<<<<<<<
             $lsl[0]     $lsl[1]     $lsl[2]     $lsl[3]     $lsl[4]     $lsl[5]     $lsl[6]     $lsl[7]     $lsl[8]     $lsl[9]     
 -------------------------------------------------------------------------------------------------------------------------------
.
/;


# ---------------
#  prepare 4 log
# ---------------
$FILE = shift || die "Please specified file to parsing...\n";
$toDir = shift || ($toDir = ".");

# generate filename for log
($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time());
$YEAR  = ($year+1900);
$MONTH = ($mon+1 <10)?('0'.($mon+1)):($mon+1);
$DAY   = ($mday  <10)?('0'. ($mday)):($mday);

# initialize logger
$logFile      = '../log/wat2dp_'.$YEAR.$MONTH.$DAY.'.log';
$logFileLists = '../log/wat2dp_'.$YEAR.$MONTH.$DAY.'.lst';
logger (("-" x 60)."\n");
logger "\nProcess file ==>".$FILE."\n";

################################################################################
# -------------------------------
# open file, get header lot info
# -------------------------------
open(FILE) || die "Cannot open file.\n";
$_ = <FILE>;
chomp;
s/[\t\'\n\r]+//g;
($lot, $process, $device, $date, $program, 
 $operator, $prober, $time, $limit, $waferCount, 
 $paramCount, $ttlChipCount, $flatDirection, $card, $criteria, 
 $cardCount, $overDrive, $totalTime)  = split /\s+/;
$product = $device;
# debug print for header
debugger "lot\t=[$lot]\n";
debugger "process\t=[$process]\n";
debugger "device\t=[$device]\n";
debugger "program\t=[$program]\n";
debugger "operator\t=[$operator]\n";
debugger "prober\t=[$prober]\n";
debugger "date\t=[$date]\n";
debugger "time\t=[$time]\n";
debugger "limit\t=[$limit]\n";
debugger "waferCount\t=[$waferCount]\n";
debugger "paramCount\t=[$paramCount]\n";
debugger "ttlChipCount\t=[$ttlChipCount]\n";
debugger "flatDirection\t=[$flatDirection]\n";
debugger "card\t=[$card]\n";
debugger "criteria\t=[$criteria]\n";
debugger "cardCount\t=[$cardCount]\n";
debugger "overDrive=\t=[$overDrive]\n";
debugger "totalTime\t=[$totalTime]\n";

$siteCount = ($ttlChipCount/$waferCount);
open(WAT, "> $toDir/dp$lot.wat1") || die "Cannot open oupput file.\n";

eval {
  # -------------------------------
  # check parameter, add new to DB
  # -------------------------------
  $limitFile  = $LIMITDIR."/".$limit;
  &getParameter;
  
  # loop for each line in rawdata
  while($line=<FILE>) {
  	chomp($line);
    
    if(
      $line =~ 
        /^\'([0-9]+)\s*\'\s+\'([0-9]+)\s*\'\s+(.+)\s+([0-9]+)\s+([0-9]+)\s*$/
      ) {
      ($wafer, $site, $testValues, $dieX, $dieY) = ($1, $2, $3, $4, $5);
      @values = split /\s+/, $testValues;
      
      #debugger "[$1], [$2], [$3], [$4], [$5], ($#parameters)==($#values)\n";
    } else {
      logger "format error on parsing each row of tested values ... \n";
      logger (("-" x 60)."\n");
      logger $line."\n";
      logger (("-" x 60)."\n");
      goto ERROR;
    }
    if($paramCount == ($#parameters+1) or $paramCount eq ($#parameters+1)) {
      $i = 0;
      foreach $parameter (@parameters){
        $data[$wafer][$site]{$parameter} = shift @values;
        #logger "[$lot], [$wafer], [$parameter], [$dieX], [$dieY], [$value] \n";
      }
    } else {
      logger "parameters($paramCount) mismatched to LIMIT file(".($parameters+1).").\n";
      goto ERROR;
    }
    #push @wafers, $wafer;
    #push @sites, $site;
    @wafers[$wafer]=$wafer;
    @sites[$site]  =$site;
  }
  #@wafers = uniq @wafers;
  #@sites  = uniq @sites;
  $pages  = int($paramCount/$paramPerPage)+1;
  eval $lotInfo;
  write WAT;
  for ($page = 1; $page<=$pages; $page++){
    debugger "($paramPerPage*$page-$paramPerPage)=".($paramPerPage*$page-$paramPerPage)." ... ".
             "($paramPerPage*$page-1)=".($paramPerPage*$page-1)."\n";
    undef  $pn; @pn  = ();
    undef   $p; @p   = ();    undef   $c; @c   = ();
    undef $usl; @usl = ();    undef $lsl; @lsl = ();
    eval $header;
    @pn = @parameters[($paramPerPage*$page-$paramPerPage) ... ($paramPerPage*$page-1)];
    foreach(@pn) {
      push   @p, $param{$_}{'name'};
      push   @c,   $param{$_}{'cl'};
      push @usl,  $param{$_}{'usl'};
      push @lsl,  $param{$_}{'lsl'};
    }
    write WAT;
    for $w (@wafers){
      next if(!$w);
      for $s (@sites){
        next if(!$s);
        eval $body;
        undef $v; @v = ();
        push(@v, $data[$w][$s]{$_}) foreach (@pn);
        write WAT;  
      }
    }
    eval $footer;
    write WAT;
  }
  logFileLists($FILE);
  # here to do *real* write back to NEDA DB
};


if($@) {
ERROR:
  close(WAT);
  close(FILE);
  warn "Transcation rollback and aborted.\n".$@."\n";
  logger "Transcation rollback and aborted.\n".$@."\n";
  exit(1);
}

close(WAT);
close(FILE);

exit;
    