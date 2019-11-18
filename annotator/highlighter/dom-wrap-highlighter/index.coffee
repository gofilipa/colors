$ = require('jquery')

# Public: Wraps the DOM Nodes within the provided range with a highlight
# element of the specified class and returns the highlight Elements.
#
# normedRange - A NormalizedRange to be highlighted.
# cssClass - A CSS class to use for the highlight (default: 'annotator-hl')
#
# Returns an array of highlight Elements.
exports.highlightRange = (normedRange, event, cssClass='annotator-hl') ->
  white = /^\s*$/

  console.log("annotation.event: ", event)
  colorClasses = event.path[0].classList # @TODO check that path exists inside event
  if colorClasses.contains('yellow')
    hlColor = 'annotator-hl--yellow'
  else if colorClasses.contains('red')
    hlColor = 'annotator-hl--red'
  else if colorClasses.contains('blue')
    hlColor = 'annotator-hl--blue'
  else
    hlColor = ''

  # A custom element name is used here rather than `<span>` to reduce the
  # likelihood of highlights being hidden by page styling.
  hl = $("<hypothesis-highlight class='#{cssClass} #{hlColor}'></hypothesis-highlight>")

  # Ignore text nodes that contain only whitespace characters. This prevents
  # spans being injected between elements that can only contain a restricted
  # subset of nodes such as table rows and lists. This does mean that there
  # may be the odd abandoned whitespace node in a paragraph that is skipped
  # but better than breaking table layouts.
  nodes = $(normedRange.textNodes()).filter((i) -> not white.test @nodeValue)

  return nodes.wrap(hl).parent().toArray()


exports.removeHighlights = (highlights) ->
  for h in highlights when h.parentNode?
    $(h).replaceWith(h.childNodes)


# Get the bounding client rectangle of a collection in viewport coordinates.
# Unfortunately, Chrome has issues[1] with Range.getBoundingClient rect or we
# could just use that.
# [1] https://code.google.com/p/chromium/issues/detail?id=324437
exports.getBoundingClientRect = (collection) ->
  # Reduce the client rectangles of the highlights to a bounding box
  rects = collection.map((n) -> n.getBoundingClientRect())
  return rects.reduce (acc, r) ->
    top: Math.min(acc.top, r.top)
    left: Math.min(acc.left, r.left)
    bottom: Math.max(acc.bottom, r.bottom)
    right: Math.max(acc.right, r.right)
