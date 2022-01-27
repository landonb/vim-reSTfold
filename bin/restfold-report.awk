#!/bin/awk -f
# vim:tw=0:ts=2:sw=2:et:norl:ft=awk
# Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
# Project: https://github.com/landonb/dubs_restfold#💤
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# USAGE:
#
#   awk -f restfold-report.awk my-file.rst
#   awk -f restfold-report.awk -v edict=XXXXX my-file.rst
#   awk -f restfold-report.awk -v edict=FIXME my-file.rst
# But really:
#   awk -f restfold-report.awk -v edict=XXXXX my-file.rst | sort -r | cut -d' ' -f2-
# And with line numbers:
#   awk -f restfold-report.awk -v edict=XXXXX my-file.rst | sort -r | cut -d' ' -f2- | nl -ba
# Note the reverse sort not only works with the number used below
# (higher is more important), the reverse sort also ensures that
# for categories and velocities that match, the next value sorted
# on will be the date (YYYY-MM-DD) in descending order.

# MEH: Option to suppress lower levels, e.g.,
#
#   awk -f restfold-report.awk -v max-level=1 my-file.rst

function process_section_border() {
  # print "Section?", $0
  if (remember_next) {
    # Two section headers in a row...??
    # Stay in the state? Or not... let's skip.
    remember_next = 0
  }
  else if (section_char) {
    # State transition: leaving section header.
    closing_char = substr($0, 0, 1)
    if (section_char != closing_char) {
      # The characters in this section do not match earlier section.
      # Start over.
      remember_next = 2
      section_char = substr($0, 0, 1)
    }
    else {
      # Success! We've identified a section header!
      # But note that the string is empty if the header did not match
      # according to the "edict" variable.
      if (section_header) {
        print section_header
      }
      section_char = ""
    }
  }
  else {
    # State transition: Current line looks like start of section header.
    remember_next = 2
    section_char = substr($0, 0, 1)
  }
}

function process_line_always() {
  if (remember_next > 0) {
    remember_next -= 1
    if (!remember_next) {
      section_header = prepare_line()
    }
  }
  else if (section_char) {
    # Saw what looked like section header, then grabbed text from next
    # line, but line after that is not a matching section header. Skip!
    section_char = "" 
  }
}

function prepare_line() {
  matching_line = ""
  if (edict) {
    # Look for "EDICT/NNNN" in line, at start of line or following a space.
    # (Note that we include the "/NNNN" to not accidentally match an otherwise
    # capitalized five-letter word that's not meant to be a FIXME-verb. This means
    # that by convention, an EDICT will always be followed by a forward slash and
    # a YYYY-MM-DD date or a NNNN ticket number (so don't check the whole y-m-d,
    # e.g., we could make the regex instead
    #     [[:digit:]]{4}.[[:digit:]]{2}.[[:digit:]]{2}
    # but let's allow unknown digits, e.g., "2020-06-XX", or any separator, not
    # just dash "-", or maybe no separator at all. Or maybe the user wants to use
    # a 4-or-more-digit ticket number and not a date. So let's not make this regex
    # unnecessarily complicated; just this comment).
    if (edict == "XXXXX") {
      match_re = "(^|[[:space:]])([[:upper:]]{5})/[[:digit:]]{4}"
    }
    else {
      match_re = "(^|[[:space:]])(" edict ")/[[:digit:]]{4}"
    }
    if ($0 ~ match_re) {
      category_rank = rank_action_category(match_re)
      velocity_rank = rank_action_velocity(match_re)

      # So that the XXXXX/YYYY-MM-DD columns align, prefix with the common
      # section header prefix that *I* use before ranked section headers, e.g.,
      #   ##########################################################
      #   ┃ 🔉 FIXME/2020-06-22: Foo Bar                           ┃
      #   ##########################################################
      # but you might have another header more simply like
      #   =========================
      #   MAYBE/2020-06-02: Baz Bat
      #   =========================
      # Then adding this prefix line will produce a report like:
      #   ┃ 🔉 FIXME/2020-06-22: Foo Bar
      #   ┃    MAYBE/2020-06-02: Baz Bat
      stripped_line = $0
      prefix_line = ""
      if (velocity_rank == "00") {
        sub(/^┃[[:space:]]*/, "", stripped_line)
        prefix_line = "┃    "
      }
      else if ($0 !~ /^┃/) {
        prefix_line = "┃ "
      }

      # We could print line unaltered: 
      #   stripped_line = $0
      # or we can strip trailing spaces and the ┃ border,
      # which I think looks better, at least when there's
      # a mix of section header formats (including those
      # with and those without borders).
      sub(/[[:space:]]*┃$/, "", stripped_line)

      # Add space after velocity to make it more easily removable by
      # caller (which can just remove first record of every line).
      matching_line = category_rank velocity_rank " " prefix_line stripped_line
    }
  }
  else {
    matching_line = $0
  }
  return matching_line
}

# ***

function rank_action_category(match_re) {
  category = extract_action_category(match_re)
  if (class && class == "number") {
    # Use _fwd if `| sort`, for when `XXXX/NNNN` where NNNN is ticket number.
    rank = convert_action_category_fwd(category)
  }
  else {
    # Use _rwd if `| sort -r`, for when `XXXX/YYYY-MM-DD`.
    rank = convert_action_category_rwd(category)
  }
  return rank
}

function extract_action_category(match_re) {
  match_re = ".*" match_re ".*"
  category = gensub(match_re, "\\2", 1, $0)
  return category
}

function convert_action_category_fwd(category) {
  cranks["FIXME"] = 100
  cranks["SPIKE"] = 200
  cranks["HIPRI"] = 220
  cranks["HIBAR"] = 240
  cranks["LATER"] = 333
  cranks["MAYBE"] = 400
  cranks["LOPRI"] = 420
  cranks["LOBAR"] = 500
  cranks["FTREQ"] = 525
  cranks["INERT"] = 555
  cranks["DEFER"] = 633
  cranks["DEBAR"] = 666
  cranks["MEHHH"] = 777
  if (cranks[category]) {
    return cranks[category]
  }
  return 900
}

# SYNC_ME: This list defines a hash similar to convert_action_category_fwd,
#          but numerically in reverse.
#          - Order the FIVER names the same, but set the first item to 900,
#            and then number down from there with the numbers from above.
function convert_action_category_rwd(category) {
  cranks["FIXME"] = 900
  cranks["SPIKE"] = 777
  cranks["HIPRI"] = 666
  cranks["HIBAR"] = 633
  cranks["LATER"] = 555
  cranks["MAYBE"] = 525
  cranks["LOPRI"] = 500
  cranks["LOBAR"] = 420
  cranks["FTREQ"] = 400
  cranks["INERT"] = 333
  cranks["DEFER"] = 240
  cranks["DEBAR"] = 220
  cranks["MEHHH"] = 200
  if (cranks[category]) {
    return cranks[category]
  }
  return 100
}

# ***

function rank_action_velocity(match_re) {
  velocity = extract_action_velocity(match_re)
  if (class && class == "number") {
    rank = convert_action_velocity_fwd(velocity)
  }
  else {
    rank = convert_action_velocity_rwd(velocity)
  }
  return rank
}

function extract_action_velocity(match_re) {
  # Pull out the prefix velocity, e.g., from
  #   ┃ 🔈 SPIKE/2019-01-27: FOO ┃
  # the velocity is '🔈'. Or, from
  #   99 SPIKE/2019-01-27: FOO
  # the velocity is '99'. Of, from
  #   SPIKE/2019-01-27: FOO
  # returns empty string because there is no velocity.

  #  match_re = "┃?[[:space:]]*(.*)[[:space:]]*" match_re ".*"
  #  match_re = "┃?[[:space:]]*([[:graph:]])[[:space:]]*" match_re ".*"
  #  match_re = "^┃?.*[[:space:]]*([[:graph:]]{1,2})[[:space:]]*" match_re ".*"
  match_re = "^┃?[[:space:]]*([[:graph:]]{1,2})[[:space:]]*" match_re ".*"
  velocity = gensub(match_re, "\\1", 1, $0)
  if (velocity == $0) {
    velocity = ""
  }
  return velocity
}

function convert_action_velocity_rwd(velocity) {
  vranks["🔊"] = 50
  vranks["🔉"] = 40
  vranks["🔈"] = 30
  vranks["🔇"] = 20
  if (vranks[velocity]) {
    return vranks[velocity]
  }
  else if (velocity && velocity != "┃") {
    # print "velocity", velocity
    # (lb): HRMM: GAWK documents a typeof(x) function, but for me it's not defined.
    #   if (typeof(velocity) == "number") { ... }
    if (strtonum(velocity)) {
      return strtonum(velocity)
    }
    else {
      return 10
    }
  }
  return "00"
}

function convert_action_velocity_fwd(velocity) {
  vranks["🔊"] = 50
  vranks["🔉"] = 60
  vranks["🔈"] = 70
  vranks["🔇"] = 80
  if (vranks[velocity]) {
    return vranks[velocity]
  }
  else if (velocity && velocity != "┃") {
    # print "velocity", velocity
    # (lb): HRMM: GAWK documents a typeof(x) function, but for me it's not defined.
    #   if (typeof(velocity) == "number") { ... }
    if (strtonum(velocity)) {
      return strtonum(velocity)
    }
    else {
      return 90
    }
  }
  return "99"
}

# ***

# This finds lines which are same character repeated 10 or more times.
# - The "XXXXX/YYYY-MM-DD" format is 15 characters. Then you'd assume
#   there's a description, but 15 will at least weed out the
#   Ctrl-Shift---created "-------" dividers.
# - SYNC_ME: This regex matches: after/syntax/rst.vim: DubsSyn_rstSections.
/^[=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]{10,}$/ {
  process_section_border()
}

{
  process_line_always()
}

