class App.Views.Editor extends Backbone.View

  initialize: ->
    for textarea in $('textarea.editor')
      $(textarea).trumbowyg
        fullscreenable: false
        svgPath: TRUMBOWYG_SVG
        btns: ['viewHTML',
          '|', 'formatting',
          '|', 'strong', 'em',
          '|', 'link',
          '|', 'insertImage',
          '|', 'justifyLeft', 'justifyCenter',
          '|', 'btnGrp-lists',
          '|', 'horizontalRule']
      .on('twbfocus', () ->
        console.log('focus!')
      )
