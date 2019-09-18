(->
  local = {}
  ldParallax = (opt = {}) ->
    @host = opt.host
    if @host == document => @host = null
    @watching = false
    handler = ~> @set-origin!
    update = (ns = []) ~>
      ns.map -> it.target._ldpx.active = it.isIntersecting
      trigger = @list.filter(-> it._ldpx.active).length 
      if trigger and !@watching => (@host or document).addEventListener \scroll, handler
      if !trigger and @watching => (@host or document).removeEventListener \scroll, handler
      @watching = trigger
    iocfg = if @host => {root: @host} else {}
    @obs = new IntersectionObserver update, iocfg
    @list = []
    @add Array.from(@host.querySelectorAll \.ldpx)
    @

  ldParallax.prototype = Object.create(Object.prototype) <<< do
    add: (n = []) ->
      n = if Array.isArray(n) => n else [n]
      n.map ~> @obs.observe it
      n.map ~> if !it._ldpx => it._ldpx = {}
      @list ++= n
      @set-origin nodes: n, force: true

    set-origin: (opt = {}) ->
      n = @host or document.scrollingElement
      y = n.scrollTop
      h = n.scrollHeight + n.getBoundingClientRect!height
      if @host =>
        box = @host.getBoundingClientRect!
        [ct,ch] = [box.y, box.height]
      else [ct, ch] = [0, window.innerHeight]
      (opt.nodes or @list)
        .filter -> opt.force or it._ldpx.active
        .map (c) ->
          box = c.getBoundingClientRect!
          percent = 100 * (box.y - (ct + ch)) / ((ct - box.height) - (ct + ch))
          c.style.perspectiveOrigin = "50% #{percent}%"

  ldParallax.init = ->
    scrollers = Array.from(document.querySelectorAll \.ldpx-scroller)
    if !scrollers.length => scrollers = [document]
    scrollers.map ->
      ldpx = new ldParallax host: document
      #ldpx.add Array.from(it.querySelectorAll \.ldpx)

  if module? => module.exports = ldParallax
  if window => window.ldParallax = ldParallax
)!
