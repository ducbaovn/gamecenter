ChatRoom.directive 'onlinePanel', [
  '$rootScope', 
  '$sails', 
  'CurrentUser', 
  ($rootScope, $sails, CurrentUser)->
    restrict: 'E'
    templateUrl: 'templates/onlines.html'
    controller: ($scope)->
      $scope.CurrentUser = CurrentUser
      $scope.show = ()=>
        console.log CurrentUser

  ]