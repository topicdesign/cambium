class App.Views.Editor extends Backbone.View

  initialize: ->
    for textarea in $('textarea.editor')
      $(textarea).trumbowyg(
        fullscreenable: false
        semantic: false
        svgPath: TRUMBOWYG_SVG
        btns: ['viewHTML',
          '|', 'formatting',
          '|', 'strong', 'em',
          '|', 'link',
          '|', 'insertImage',
          '|', 'justifyLeft', 'justifyCenter',
          '|', 'btnGrp-lists',
          '|', 'horizontalRule']
      )
      .on('tbwfocus', () ->
        console.log('focused')
      )
