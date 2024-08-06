# PyCall crash when run within Puma

Minimal repro of a call to a python library that crashes when run inside Puma (e.g. Ruby on Rails)
but does not crash when run outside Puma. Puma is configured to only spawn one thread (see puma.rb).

The PyCall code that crashes puma is (in ruby, see `crash_puma.rb`):

```
input_scanners = PyCall.import_module('llm_guard.input_scanners')
input_scanners.Toxicity() # SEGV if run in puma, works if run directly
```

The equivalent in python would be:

```
from llm_guard import input_scanners
input_scanners.Toxicity()
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
*          PID: 20025
* Listening on http://0.0.0.0:9292
Use Ctrl-C to stop
About to do a wget which will crash puma...
--2024-08-06 04:01:08--  http://localhost:9292/
Resolving localhost (localhost)... ::1, 127.0.0.1
Connecting to localhost (localhost)|::1|:9292... failed: Connection refused.
Connecting to localhost (localhost)|127.0.0.1|:9292... connected.
HTTP request sent, awaiting response... /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.rb:82: [BUG] Segmentation fault at 0x0000000000000010
ruby 3.0.5p211 (2022-11-24 revision ba5cf0f7c5) [arm64-darwin23]

-- Crash Report log information --------------------------------------------
   See Crash Report log file under the one of following:
     * ~/Library/Logs/DiagnosticReports
     * /Library/Logs/DiagnosticReports
   for more details.
Don't forget to include the above Crash Report log file in bug reports.

-- Control frame information -----------------------------------------------
c:0012 p:---- s:0077 e:000076 CFUNC  :import_module
c:0011 p:0017 s:0072 e:000071 METHOD /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.rb:82
c:0010 p:0013 s:0067 e:000066 METHOD /Users/seth/src/pycall_puma_crash/crash_puma.rb:16
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
/Users/seth/src/pycall_puma_crash/crash_puma.rb:16:in `do_crash'
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

102cc0000-102cc4000 r-x /Users/seth/.rbenv/versions/3.0.5/bin/ruby
102cc4000-102cc8000 r-- /Users/seth/.rbenv/versions/3.0.5/bin/ruby
102cc8000-102ccc000 r-- /Users/seth/.rbenv/versions/3.0.5/bin/ruby
102ccc000-102cd0000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
102cd0000-102cd4000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
102cdc000-102ce0000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
102ce0000-102ce4000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
102ce4000-102ce8000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
102ce8000-102cec000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/encdb.bundle
102cec000-102cf0000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/trans/transdb.bundle
102cf0000-102cf4000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/trans/transdb.bundle
102cf4000-102cf8000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/trans/transdb.bundle
102cf8000-102cfc000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/enc/trans/transdb.bundle
102d0c000-102d10000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/monitor.bundle
102d10000-102d14000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/monitor.bundle
102d14000-102d18000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/monitor.bundle
102d18000-102d1c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/monitor.bundle
102d1c000-102d20000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/io/wait.bundle
102d20000-102d24000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/io/wait.bundle
102d24000-102d28000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/io/wait.bundle
102d28000-102d2c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/io/wait.bundle
102d2c000-102d30000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/etc.bundle
102d30000-102d34000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/etc.bundle
102d34000-102d38000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/etc.bundle
102d38000-102d3c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/etc.bundle
102d58000-102d7c000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
102d7c000-102d80000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
102d80000-102d84000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
102d84000-102d94000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/socket.bundle
102d94000-102dd4000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
102dd4000-102ddc000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
102ddc000-102de0000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
102de0000-102de4000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
102de4000-102de8000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/stringio-3.1.1/lib/stringio.bundle
102de8000-102df0000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/puma_http11.bundle
102df0000-102df4000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/puma_http11.bundle
102df4000-102df8000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/puma_http11.bundle
102df8000-102dfc000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/puma-6.4.2/lib/puma/puma_http11.bundle
102dfc000-102e04000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/fiddle.bundle
102e04000-102e08000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/fiddle.bundle
102e08000-102e0c000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/fiddle.bundle
102e0c000-102e14000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/fiddle.bundle
102e14000-102e1c000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/pathname.bundle
102e1c000-102e20000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/pathname.bundle
102e20000-102e24000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/pathname.bundle
102e24000-102e28000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/3.0.0/arm64-darwin23/pathname.bundle
102e28000-102e34000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
102e34000-102e38000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
102e38000-102e3c000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
102e3c000-102e44000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/nio4r-2.7.3/lib/nio4r_ext.bundle
102e48000-102e58000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.bundle
102e58000-102e5c000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.bundle
102e5c000-102e60000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.bundle
102e60000-102e68000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/ruby/gems/3.0.0/gems/pycall-1.5.2/lib/pycall.bundle
102e78000-102ec4000 r-x /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libssl.1.1.dylib
102ec4000-102ed0000 r-- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libssl.1.1.dylib
102ed0000-102ed4000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libssl.1.1.dylib
102ed4000-102ef4000 r-- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libssl.1.1.dylib
102f00000-103000000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
1030d0000-103110000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103110000-103114000 --- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103114000-10311c000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
10311c000-103120000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103120000-103124000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103124000-103128000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103128000-10312c000 --- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
10312c000-103138000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103138000-10313c000 --- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
10313c000-103140000 --- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103140000-10314c000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
10314c000-103150000 --- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103150000-103154000 --- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103154000-103160000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103160000-103164000 --- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103164000-103168000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103168000-103268000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
103300000-103400000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
1034d4000-1037b8000 r-x /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
1037b8000-1037c0000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
1037c0000-1037c4000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
1037c4000-1037d0000 rw- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
1037d0000-1038a0000 r-- /Users/seth/.rbenv/versions/3.0.5/lib/libruby.3.0.dylib
1038a0000-1038a4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1038a4000-103948000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103948000-10394c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10394c000-1039f0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1039f0000-1039f4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1039f4000-103a98000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103a98000-103a9c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103a9c000-103b40000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103b40000-103b44000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103b44000-103be8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103be8000-103bec000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103bec000-103c90000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103c90000-103c94000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103c94000-103d38000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103d38000-103d3c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103d3c000-103de0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103de0000-103de4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103de4000-103e88000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103e88000-103e8c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103e8c000-103f30000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103f30000-103f34000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103f34000-103fd8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103fd8000-103fdc000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
103fdc000-104080000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104080000-104084000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104084000-104128000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104128000-10412c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10412c000-1041d0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1041d0000-1041d4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1041d4000-104278000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104278000-10427c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10427c000-104320000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104320000-104324000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104324000-1043c8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1043c8000-1043cc000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1043cc000-104470000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104470000-104474000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104474000-104518000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104518000-10451c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10451c000-1045c0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1045c0000-1045c4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1045c4000-104668000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104668000-10466c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10466c000-104710000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104710000-104714000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104714000-1047b8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1047b8000-1047bc000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1047bc000-104860000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104860000-104864000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104864000-104908000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104908000-10490c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
10490c000-1049b0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1049b0000-1049b4000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
1049b4000-104a58000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104a58000-104a5c000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104a5c000-104b00000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104b00000-104b04000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104b04000-104ba8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104ba8000-104bac000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104bac000-104c50000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104c50000-104c54000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104c54000-104cf8000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104cf8000-104cfc000 --- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104cfc000-104da0000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104da0000-104f20000 r-x /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104f20000-104f4c000 r-- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104f4c000-104f50000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104f50000-104f54000 rw- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
104f54000-104fbc000 r-- /opt/homebrew/Cellar/openssl@1.1/1.1.1w/lib/libcrypto.1.1.dylib
105000000-105800000 rw- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
105800000-105900000 rw- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
105dbc000-1060e0000 r-x /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
1060e0000-106158000 r-- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
106158000-1062b4000 rw- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
1062b4000-106378000 r-- /opt/homebrew/Cellar/python@3.12/3.12.4/Frameworks/Python.framework/Versions/3.12/Python
106800000-107000000 rw-
10be00000-10bf00000 rw-
10bf00000-10c000000 rw-
10c000000-10c100000 rw-
10c100000-10c200000 rw-
10c800000-10d000000 rw-
110000000-118000000 rw-
11be00000-11bf00000 rw-
11bf00000-11c000000 rw-
11c000000-11c800000 rw-
120000000-128000000 rw-
12be00000-12bf00000 rw-
12bf00000-12c000000 rw-
12c000000-12c800000 rw-
130000000-138000000 rw-
13be00000-13bf00000 rw-
13bf00000-13bf04000 rw-
13c000000-13c800000 rw-
13c800000-13e800000 rw-
13e800000-13e900000 rw-
13f000000-13f800000 rw-
140000000-148000000 rw-
148000000-150000000 rw-
150000000-158000000 rw-
158000000-160000000 rw-
169140000-16c944000 ---
16c944000-16d140000 rw-
16d140000-16d144000 ---
16d144000-16d1cc000 rw-
16d1cc000-16d1d0000 ---
16d1d0000-16d3d8000 rw-
16d3d8000-16d3dc000 ---
16d3dc000-16d5e4000 rw-
16d5e4000-16d5e8000 ---
16d5e8000-16d7f0000 rw-
16d7f0000-16d7f4000 ---
16d7f4000-16d9fc000 rw-
16d9fc000-16da00000 ---
16da00000-16dc08000 rw-
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

No data received.
Retrying.

--2024-08-06 04:01:09--  (try: 2)  http://localhost:9292/
Connecting to localhost (localhost)|127.0.0.1|:9292... failed: Connection refused.
Resolving localhost (localhost)... ::1, 127.0.0.1
Connecting to localhost (localhost)|::1|:9292... failed: Connection refused.
Connecting to localhost (localhost)|127.0.0.1|:9292... failed: Connection refused.
./crash_puma.sh: line 11: 20025 Abort trap: 6           puma -C puma.rb config.ru
```
