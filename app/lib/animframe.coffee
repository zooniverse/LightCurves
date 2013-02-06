###
http://notes.jetienne.com/2011/05/18/cancelRequestAnimFrame-for-paul-irish-requestAnimFrame.html
###

window.cancelRequestAnimFrame = (->
  window.cancelAnimationFrame or 
  window.webkitCancelRequestAnimationFrame or 
  window.mozCancelRequestAnimationFrame or 
  window.oCancelRequestAnimationFrame or 
  window.msCancelRequestAnimationFrame or 
  clearTimeout
)()

window.requestAnimFrame = (->
  window.requestAnimationFrame or 
  window.webkitRequestAnimationFrame or 
  window.mozRequestAnimationFrame or 
  window.oRequestAnimationFrame or 
  window.msRequestAnimationFrame or 
  (callback, element) -> 
    window.setTimeout callback, 1000 / 60
)()


