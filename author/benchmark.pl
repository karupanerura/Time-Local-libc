use strict;
use warnings;

use Test::Builder;
use Time::Duration;
use Benchmark qw/cmpthese timethese/;

use Time::Local ();
use Time::Local::libc ();

use constant DEBUG => $ENV{DEBUG} ? 1 : 0;
sub say { print @_, $/ }

exit main() || 0;

sub main {
    my @patterns = create_patterns();

    print 'run testing ... ';
    my $is_passing = do_test(@patterns);
    if ($is_passing) {
        say 'All tests successful!';
        do_benchmark(@patterns);
    }
    else {
        die 'Testing failed.';
    }
}

sub do_test {
    my @patterns = @_;

    my $t = Test::Builder->create;
    unless (DEBUG) {
        $t->output(\my $output);
        $t->todo_output(\my $todo_output);
    }
    $t->no_plan();
    for my $type (qw/timegm timelocal/) {
        for my $module (qw/Time::Local::libc/) {
            my $srcfunc = Time::Local->can($type);
            my $myfunc  = $module->can($type);
            $t->subtest("${module}::${type}" => sub {
                $t->expected_tests(scalar @patterns);
                for my $pattern (@patterns) {
                    my @args = @$pattern;
                    my $src  = $srcfunc->(@args);
                    my $mine = $myfunc->(@args);
                    my $name = sprintf "%02d-%02d-%02dT%02d:%02d:%02dZ\tduration:%s", $args[5], $args[4]+1, @args[3,2,1,0], duration($src - $mine);
                    $t->is_num($mine, $src, $name);
                }
            });
        }
    }
    $t->done_testing(2);
    return $t->is_passing;
}

sub do_benchmark {
    my @patterns = @_;

    say 'run benchmarking: timegm ...';
    cmpthese timethese -10 => +{
        orig => sub {
            Time::Local::timegm(@$_) for @patterns;
        },
        libc => sub {
            Time::Local::libc::timegm(@$_) for @patterns;
        },
    };

    say 'run benchmarking: timelocal ...';
    cmpthese timethese -10 => +{
        orig => sub {
            Time::Local::timelocal(@$_) for @patterns;
        },
        libc => sub {
            Time::Local::libc::timelocal(@$_) for @patterns;
        },
    };
}

sub create_patterns {
    my @MONTH_DAYS = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

    my @patterns;
    for my $year (1970, 1972, 2000, 2020, 2100) {
        for my $month (1..12) {
            for my $day (1, 10, 20, $MONTH_DAYS[$month - 1]) {
                for my $hour (0, 4, 12, 20, 23) {
                    for my $min (0, 14, 53, 59) {
                        for my $sec (0, 30, 59) {
                            push @patterns => [$sec, $min, $hour, $day, $month - 1, $year - 1900];
                        }
                    }
                }
            }
        }
    }

    return @patterns;
}
__END__
run testing ... All tests successful!
run benchmarking: timegm ...
Benchmark: running libc, orig for at least 10 CPU seconds...
      libc: 10 wallclock secs (10.04 usr +  0.01 sys = 10.05 CPU) @ 14.73/s (n=148)
      orig: 11 wallclock secs (10.68 usr +  0.00 sys = 10.68 CPU) @ 24.81/s (n=265)
       Rate libc orig
libc 14.7/s   -- -41%
orig 24.8/s  68%   --
run benchmarking: timelocal ...
Benchmark: running libc, orig for at least 10 CPU seconds...
      libc: 10 wallclock secs (10.74 usr +  0.01 sys = 10.75 CPU) @ 25.67/s (n=276)
      orig: 11 wallclock secs (10.19 usr +  0.01 sys = 10.20 CPU) @  5.10/s (n=52)
       Rate orig libc
orig 5.10/s   -- -80%
libc 25.7/s 404%   --
