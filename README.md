# PyCall crash when run within Puma

Minimal repro of a call to a python library that crashes when run inside Puma (e.g. Ruby on Rails)
but does not crash when run outside Puma. Puma is configured to only spawn one thread (see puma.rb).

The PyCall code that crashes puma is (in ruby, see `crash_puma.rb`):

```
pandas = PyCall.import_module('pandas')
data = pandas.read_csv('https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv', sep: ';')
```

The equivalent in python would be:

```
import pandas
data = pandas.read_csv('https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv', sep=';')
```

## Setup

1. `pdm install` # this will install python and make a venv in .venv, `brew install pdm` if you don't have it
1. `rbenv local` # should show ruby 3.0.5, `brew install rbenv` if you don't have it

## The PyCall Works Without Puma

Try:

```
./crash_puma.rb

#=> About to crash (if running in puma)
#=> IT DID NOT CRASH
```

# The PyCall Crashes With Puma

Try:

```
./crash_puma.sh
```

This results in:

```
pycall_puma_crash git:(main) ✗ ./crash_puma.sh
Puma starting in single mode...
* Puma version: 6.4.2 (ruby 3.0.5-p211) ("The Eagle of Durango")
*  Min threads: 1
*  Max threads: 1
*  Environment: development
*          PID: 48554
* Listening on http://0.0.0.0:9292
Use Ctrl-C to stop
About to do a curl which will crash puma...
About to crash (if running in puma)
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.rb:82: [BUG] Segmentation fault at 0x0000000000000010
ruby 3.0.5p211 (2022-11-24 revision ba5cf0f7c5) [arm64-darwin23]

-- Crash Report log information --------------------------------------------
   See Crash Report log file under the one of following:
     * ~/Library/Logs/DiagnosticReports
     * /Library/Logs/DiagnosticReports
   for more details.
Don't forget to include the above Crash Report log file in bug reports.

-- Control frame information -----------------------------------------------
c:0012 p:---- s:0078 e:000077 CFUNC  :import_module
c:0011 p:0017 s:0073 e:000072 METHOD /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.rb:82
c:0010 p:0019 s:0068 e:000067 METHOD /Users/seth/src/pycall_puma_crash/crash_puma.rb:18
c:0009 p:0011 s:0062 e:000061 METHOD /Users/seth/src/pycall_puma_crash/app.rb:5
c:0008 p:0028 s:0057 e:000056 METHOD /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/configuration.rb:272
c:0007 p:0008 s:0052 e:000051 BLOCK  /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/request.rb:100
c:0006 p:0023 s:0049 e:000048 METHOD /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/thread_pool.rb:378
c:0005 p:0465 s:0044 e:000043 METHOD /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/request.rb:99
c:0004 p:0128 s:0029 e:000028 METHOD /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/server.rb:464
c:0003 p:0006 s:0018 e:000017 BLOCK  /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/server.rb:245
c:0002 p:0086 s:0014 e:000013 BLOCK  /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/thread_pool.rb:155 [FINISH]
c:0001 p:---- s:0003 e:000002 (none) [FINISH]

-- Ruby level backtrace information ----------------------------------------
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/thread_pool.rb:155:in `block in spawn_thread'
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/server.rb:245:in `block in run'
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/server.rb:464:in `process_client'
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/request.rb:99:in `handle_request'
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/thread_pool.rb:378:in `with_force_shutdown'
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/request.rb:100:in `block in handle_request'
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/configuration.rb:272:in `call'
/Users/seth/src/pycall_puma_crash/app.rb:5:in `call'
/Users/seth/src/pycall_puma_crash/crash_puma.rb:18:in `do_crash'
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.rb:82:in `import_module'
/Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.rb:82:in `import_module'

-- Other runtime information -----------------------------------------------

* Loaded script: /Users/seth/.rbenv/versions/3.0.5/bin/puma

* Loaded features:

    0 enumerator.so
    1 thread.rb
    2 rational.so
    3 complex.so
    4 ruby2_keywords.rb
    5 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
    6 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/trans/transdb.bundle
    7 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/rbconfig.rb
    8 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/compatibility.rb
    9 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/defaults.rb
   10 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/deprecate.rb
   11 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/errors.rb
   12 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/exceptions.rb
   13 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/basic_specification.rb
   14 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/stub_specification.rb
   15 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/text.rb
   16 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/user_interaction.rb
   17 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/specification_policy.rb
   18 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/util/list.rb
   19 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/platform.rb
   20 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/version.rb
   21 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/requirement.rb
   22 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/specification.rb
   23 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/util.rb
   24 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/dependency.rb
   25 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/core_ext/kernel_gem.rb
   26 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/monitor.bundle
   27 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/monitor.rb
   28 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/core_ext/kernel_require.rb
   29 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/core_ext/kernel_warn.rb
   30 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/path_support.rb
   31 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/bundler_version_finder.rb
   32 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems.rb
   33 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/version.rb
   34 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/core_ext/name_error.rb
   35 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/levenshtein.rb
   36 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/jaro_winkler.rb
   37 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/spell_checker.rb
   38 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/spell_checkers/name_error_checkers/class_name_checker.rb
   39 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/spell_checkers/name_error_checkers/variable_name_checker.rb
   40 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/spell_checkers/name_error_checkers.rb
   41 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/spell_checkers/method_name_checker.rb
   42 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/spell_checkers/key_error_checker.rb
   43 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/spell_checkers/null_checker.rb
   44 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/tree_spell_checker.rb
   45 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/spell_checkers/require_path_checker.rb
   46 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean/formatters/plain_formatter.rb
   47 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/did_you_mean.rb
   48 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/tsort/lib/tsort.rb
   49 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/tsort.rb
   50 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/request_set/gem_dependency_api.rb
   51 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/request_set/lockfile/parser.rb
   52 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/request_set/lockfile/tokenizer.rb
   53 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/request_set/lockfile.rb
   54 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/request_set.rb
   55 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/gem_metadata.rb
   56 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/delegates/specification_provider.rb
   57 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/errors.rb
   58 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph/action.rb
   59 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph/add_edge_no_circular.rb
   60 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph/add_vertex.rb
   61 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph/delete_edge.rb
   62 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph/detach_vertex_named.rb
   63 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph/set_payload.rb
   64 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph/tag.rb
   65 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph/log.rb
   66 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph/vertex.rb
   67 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/dependency_graph.rb
   68 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/state.rb
   69 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/modules/specification_provider.rb
   70 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/delegates/resolution_state.rb
   71 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/resolution.rb
   72 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/resolver.rb
   73 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo/modules/ui.rb
   74 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo/lib/molinillo.rb
   75 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/molinillo.rb
   76 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/activation_request.rb
   77 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/conflict.rb
   78 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/dependency_request.rb
   79 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/requirement_list.rb
   80 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/stats.rb
   81 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/set.rb
   82 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/api_set.rb
   83 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/composed_set.rb
   84 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/best_set.rb
   85 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/current_set.rb
   86 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/git_set.rb
   87 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/index_set.rb
   88 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/installer_set.rb
   89 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/lock_set.rb
   90 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/vendor_set.rb
   91 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/source_set.rb
   92 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/specification.rb
   93 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/spec_specification.rb
   94 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/api_specification.rb
   95 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/git_specification.rb
   96 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/index_specification.rb
   97 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/installed_specification.rb
   98 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/local_specification.rb
   99 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/lock_specification.rb
  100 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver/vendor_specification.rb
  101 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/resolver.rb
  102 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/source/git.rb
  103 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/source/installed.rb
  104 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/source/specific_file.rb
  105 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/source/local.rb
  106 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/source/lock.rb
  107 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/source/vendor.rb
  108 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/rubygems/source.rb
  109 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/set-1.0.3/lib/set.rb
  110 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/optparse.rb
  111 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/version.rb
  112 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/rfc2396_parser.rb
  113 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/rfc3986_parser.rb
  114 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/common.rb
  115 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/generic.rb
  116 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/file.rb
  117 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/ftp.rb
  118 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/http.rb
  119 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/https.rb
  120 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/ldap.rb
  121 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/ldaps.rb
  122 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/mailto.rb
  123 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/ws.rb
  124 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri/wss.rb
  125 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/uri-0.13.0/lib/uri.rb
  126 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
  127 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/io/wait.bundle
  128 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/socket.rb
  129 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/delegate.rb
  130 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/fileutils.rb
  131 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/etc.bundle
  132 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/tmpdir.rb
  133 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/tempfile.rb
  134 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
  135 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/puma_http11.bundle
  136 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/detect.rb
  137 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/json_serialization.rb
  138 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/open3.rb
  139 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/minissl.rb
  140 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma.rb
  141 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/rack/builder.rb
  142 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/plugin.rb
  143 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/const.rb
  144 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/util.rb
  145 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/dsl.rb
  146 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/configuration.rb
  147 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/null_io.rb
  148 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/error_logger.rb
  149 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/log_writer.rb
  150 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/events.rb
  151 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/io_buffer.rb
  152 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/thread_pool.rb
  153 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/reactor.rb
  154 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/client.rb
  155 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/minissl/context_builder.rb
  156 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/binder.rb
  157 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/request.rb
  158 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/server.rb
  159 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/runner.rb
  160 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/cluster/worker_handle.rb
  161 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/cluster/worker.rb
  162 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/cluster.rb
  163 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/single.rb
  164 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/launcher.rb
  165 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/cli.rb
  166 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/rack-2.2.9/lib/rack/version.rb
  167 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/rack-2.2.9/lib/rack.rb
  168 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/rack-2.2.9/lib/rack/builder.rb
  169 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/rack-2.2.9/lib/rack/server.rb
  170 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/version.rb
  171 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/error.rb
  172 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/fiddle.bundle
  173 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/fiddle/closure.rb
  174 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/fiddle/function.rb
  175 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/fiddle/version.rb
  176 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/fiddle.rb
  177 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/pathname.bundle
  178 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/pathname.rb
  179 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/libpython/finder.rb
  180 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/libpython.rb
  181 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/pyerror.rb
  182 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/wrapper_object_cache.rb
  183 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/pyobject_wrapper.rb
  184 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/pytypeobject_wrapper.rb
  185 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/pymodule_wrapper.rb
  186 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/iterable_wrapper.rb
  187 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/init.rb
  188 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.rb
  189 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.bundle
  190 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/dict.rb
  191 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/list.rb
  192 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall/slice.rb
  193 /Users/seth/src/pycall_puma_crash/crash_puma.rb
  194 /Users/seth/src/pycall_puma_crash/app.rb
  195 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio/version.rb
  196 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
  197 /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio.rb

* Process memory map:

100030000-100034000 r-x /Users/seth/.rbenv/versions/3.0.5/bin/ruby
100034000-100038000 r-- /Users/seth/.rbenv/versions/3.0.5/bin/ruby
100038000-10003c000 r-- /Users/seth/.rbenv/versions/3.0.5/bin/ruby
10003c000-100040000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
100040000-100044000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
10004c000-100050000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
100050000-100054000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
100054000-100058000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
100058000-10005c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
10005c000-100060000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/trans/transdb.bundle
100060000-100064000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/trans/transdb.bundle
100064000-100068000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/trans/transdb.bundle
100068000-10006c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/trans/transdb.bundle
10007c000-100080000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/monitor.bundle
100080000-100084000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/monitor.bundle
100084000-100088000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/monitor.bundle
100088000-10008c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/monitor.bundle
10008c000-100090000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/io/wait.bundle
100090000-100094000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/io/wait.bundle
100094000-100098000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/io/wait.bundle
100098000-10009c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/io/wait.bundle
10009c000-1000a0000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/etc.bundle
1000a0000-1000a4000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/etc.bundle
1000a4000-1000a8000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/etc.bundle
1000a8000-1000ac000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/etc.bundle
1000ac000-1000ec000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
100100000-100200000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
100200000-100300000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
100300000-100400000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
100400000-100424000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
100424000-100428000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
100428000-10042c000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
10042c000-10043c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
100440000-100480000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
100480000-100484000 --- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
100484000-10048c000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
10048c000-100490000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
100490000-100494000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
100494000-100498000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
100498000-10049c000 --- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
10049c000-1004a8000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004a8000-1004ac000 --- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004ac000-1004b0000 --- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004b0000-1004bc000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004bc000-1004c0000 --- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004c0000-1004c4000 --- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004c4000-1004d0000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004d0000-1004d4000 --- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004d4000-1004d8000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004d8000-1004e0000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004e0000-1004e4000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004e4000-1004e8000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004e8000-1004ec000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
1004ec000-1004f4000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/puma_http11.bundle
1004f4000-1004f8000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/puma_http11.bundle
1004f8000-1004fc000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/puma_http11.bundle
1004fc000-100500000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/puma_http11.bundle
100500000-100508000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/pathname.bundle
100508000-10050c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/pathname.bundle
10050c000-100510000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/pathname.bundle
100510000-100514000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/pathname.bundle
100518000-100520000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/fiddle.bundle
100520000-100524000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/fiddle.bundle
100524000-100528000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/fiddle.bundle
100528000-100530000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/fiddle.bundle
100550000-100560000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.bundle
100560000-100564000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.bundle
100564000-100568000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.bundle
100568000-100570000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.bundle
10057c000-1005c8000 r-x /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libssl.1.1.dylib
1005c8000-1005d4000 r-- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libssl.1.1.dylib
1005d4000-1005d8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libssl.1.1.dylib
1005d8000-1005f8000 r-- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libssl.1.1.dylib
100600000-100700000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
100700000-100800000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
100800000-10080c000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
10080c000-100810000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
100810000-100814000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
100814000-10081c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
100844000-100b28000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
100b28000-100b30000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
100b30000-100b34000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
100b34000-100b40000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
100b40000-100c10000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
100c10000-100c14000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100c14000-100cb8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100cb8000-100cbc000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100cbc000-100d60000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100d60000-100d64000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100d64000-100e08000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100e08000-100e0c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100e0c000-100eb0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100eb0000-100eb4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100eb4000-100f58000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100f58000-100f5c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
100f5c000-101000000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101000000-101004000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101004000-1010a8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1010a8000-1010ac000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1010ac000-101150000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101150000-101154000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101154000-1011f8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1011f8000-1011fc000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1011fc000-1012a0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1012a0000-1012a4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1012a4000-101348000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101348000-10134c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10134c000-1013f0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1013f0000-1013f4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1013f4000-101498000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101498000-10149c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10149c000-101540000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101540000-101544000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101544000-1015e8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1015e8000-1015ec000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1015ec000-101690000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101690000-101694000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101694000-101738000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101738000-10173c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10173c000-1017e0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1017e0000-1017e4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1017e4000-101888000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101888000-10188c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10188c000-101930000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101930000-101934000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101934000-1019d8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1019d8000-1019dc000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1019dc000-101a80000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101a80000-101a84000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101a84000-101b28000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101b28000-101b2c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101b2c000-101bd0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101bd0000-101bd4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101bd4000-101c78000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101c78000-101c7c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101c7c000-101d20000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101d20000-101d24000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101d24000-101dc8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101dc8000-101dcc000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101dcc000-101e70000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101e70000-101e74000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101e74000-101f18000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101f18000-101f1c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101f1c000-101fc0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101fc0000-101fc4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
101fc4000-102068000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
102068000-10206c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10206c000-102110000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
102110000-102290000 r-x /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
102290000-1022bc000 r-- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1022bc000-1022c0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1022c0000-1022c4000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1022c4000-10232c000 r-- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
102400000-102500000 rw- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
102500000-102600000 rw- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
102600000-102700000 rw- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
102800000-103000000 rw- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
103000000-103800000 rw- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
103dbc000-1040e0000 r-x /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
1040e0000-104158000 r-- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
104158000-1042b4000 rw- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
1042b4000-104378000 r-- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
10ee00000-10ef00000 rw-
10f000000-10f800000 rw-
110000000-118000000 rw-
11ee00000-11ef00000 rw-
11f000000-11f800000 rw-
120000000-128000000 rw-
12ee00000-12ef00000 rw-
12ef00000-12ef04000 rw-
12f000000-12f800000 rw-
12f800000-12f900000 rw-
130000000-138000000 rw-
138000000-13a000000 rw-
13a000000-13a800000 rw-
140000000-148000000 rw-
148000000-150000000 rw-
16bdd0000-16f5d4000 ---
16f5d4000-16fdd0000 rw-
16fdd0000-16fdd4000 ---
16fdd4000-16fe5c000 rw-
16fe5c000-16fe60000 ---
16fe60000-170068000 rw-
170068000-17006c000 ---
17006c000-170274000 rw-
170274000-170278000 ---
170278000-170480000 rw-
170480000-170484000 ---
170484000-17068c000 rw-
17068c000-170690000 ---
170690000-170898000 rw-
180000000-1f4000000 r--
1f4000000-1f57f8000 r--
1f57f8000-1f581c000 rw-
1f581c000-1f6000000 rw-
1f6000000-1f68bc000 r--
1f68bc000-1fb68c000 rw-
1fb68c000-200ef8000 r--
200ef8000-202000000 r--
202000000-266000000 r--
266000000-26744c000 rw-
26744c000-26b1c0000 rw-
26b1c0000-26d348000 r--
26d348000-26e000000 r--
26e000000-300000000 r--
fc0000000-1000000000 ---
1000000000-7000000000 ---
[IMPORTANT]
Don't forget to include the Crash Report log file under
DiagnosticReports directory in bug reports.

curl: (52) Empty reply from server
./crash_puma.sh: line 10: 48554 Abort trap: 6           puma -C puma.rb config.ru
./crash_puma.sh: line 12: kill: (48554) - No such process
```
