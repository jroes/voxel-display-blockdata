# This is entirely based on https://github.com/deathcap/voxel-voila/

module.exports = (game, opts) -> new DisplayBlockdataPlugin(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-highlight', 'voxel-blockdata']
  clientOnly: true

class DisplayBlockdataPlugin
  constructor: (@game, opts) ->
    @hl = @game.plugins?.get('voxel-highlight') ? throw 'voxel-display-blockdata requires voxel-highlight plugin'
    @blockdata = @game.plugins?.get('voxel-blockdata')

    @createNode()

    @enable()

  createNode: () ->
    @node = document.createElement 'div'
    @node.setAttribute 'id', 'voxel-display-blockdata'
    @node.setAttribute 'style', '
border: 1px solid black;
background-image: linear-gradient(rgba(0,0,0,0.6) 0%, rgba(0,0,0,0.6) 100%);
position: absolute;
visibility: hidden;
top: 0px;
left: 50%;
color: white;
font-size: 18pt;
'
    @node.textContent = ''

    document.body.appendChild(@node)

  update: (pos) ->
    @lastPos = pos
    if not @lastPos?
      @clear()
      return

    if @blockdata?
      # optional attached arbitrary block data
      [x, y, z] = pos
      bd = @blockdata.get(x, y, z)
      if bd?
        content = "#{JSON.stringify(bd)}"
        window.status = content
        @node.textContent = content

  clear: () ->
    @lastPos = undefined
    @node.textContent = ''

  enable: () ->
    @node.style.visibility = ''

    @hl.on 'highlight', @onHighlight = (pos) =>
      @update(pos)

    @hl.on 'remove', @onRemove = () =>
      @clear()

    if @game.buttons.changed? # available in kb-bindings >=0.2.0
      @game.buttons.changed.on 'crouch', @onChanged = () =>
        @update(@lastPos)


  disable: () ->
    @hl.removeListener 'highlight', @onHighlight
    @hl.removeListener 'remove', @onRemove
    @game.buttons.changed.removeListener 'crouch', @onChanged if @game.buttons.changed?
    @node.style.visibility = 'hidden'

