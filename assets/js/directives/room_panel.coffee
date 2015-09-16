ChatRoom.directive 'roomPanel', [
  '$rootScope', 
  '$sails', 
  'CurrentUser', 
  ($rootScope, $sails, CurrentUser)->
    restrict: 'E'
    templateUrl: 'templates/rooms.html'
    controller: ($scope)->
      $scope.CurrentUser = CurrentUser
      $scope.show = ()=>
        console.log CurrentUser

  ]