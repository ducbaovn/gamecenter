ChatRoom.directive 'ngEnter', [
  '$rootScope', 
  ($rootScope)->
    restrict: 'E'
    link: (scope,element,attrs)->
      element.bind "keypress", (event)->
        if event.which == 13
          scope.$apply ()->
            scope.$eval(attrs.ngEnter)
          event.preventDefault()

  ]