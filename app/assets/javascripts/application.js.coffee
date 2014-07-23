#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require social-share-button
#= require bootstrap
#= require jquery.autosize
#= require jquery.validate
#= require jquery.timeago
#= require nprogress
#= require campo
#= require simditor-all
#= require_tree ./plugins

$(document).on 'page:update', ->
  $('[data-behaviors~=autosize]').autosize()

  $("time[data-behaviors~=timeago]").timeago()

$(document).on 'page:fetch', ->
  NProgress.start()
$(document).on 'page:change', ->
  NProgress.done()
$(document).on 'page:restore', ->
  NProgress.remove()

$(document).on 'page:change', ->
  $('#arrow-up').on 'click', ->
    # $(document).scrollTop(0)
    $("html, body").animate({ scrollTop: 0 }, "slow")

$(document).scroll ->

  if $(document).scrollTop() < 200
    $('#arrow-up').removeClass('show')
  else
    $('#arrow-up').addClass('show')

