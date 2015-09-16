ChatRoom.directive 'roomDetailPanel', [
  '$rootScope', 
  '$sails', 
  'CurrentUser', 
  ($rootScope, $sails, CurrentUser)->
    restrict: 'E'
    templateUrl: 'templates/room_details.html'
    controller: ($scope)->
      $scope.CurrentUser = CurrentUser
      $scope.show = ()=>
        console.log CurrentUser

  ]