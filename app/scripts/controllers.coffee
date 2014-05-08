'use strict'

angular.module('taarifaWaterpointsApp')
  .controller 'MainCtrl', ($scope, Waterpoint) ->
    Waterpoint.query (waterpoints) ->
      $scope.waterpoints = waterpoints._items
  .controller 'MapCtrl', ($http, $scope, Waterpoint) ->
    $scope.dar =
      lat: -6.7701973
      lng: 39.2664484
      zoom: 6
    $scope.markers = {}
    addMarkers = (waterpoints) ->
      for p in waterpoints._items
        $scope.markers[p._id] =
          group: p.district
          lat: p.latitude
          lng: p.longitude
          message: "<h1 class=\"title wpt_name\">#{p.wpt_name}</h1><div class=\"wpt_code\">#{p.wpt_code}</div><div class=\"status status-#{p.status.replace(/\s+/g, '-').toLowerCase()}\">Status: <span>#{p.status}</span></div><div class=\"text-center controls\">
            <a class=\"btn btn-primary btn-xs\" href=\"#/waterpoints/edit/#{p._id}\">edit</a>
          </div>"
      # This would keep loading further waterpoints as long as there are any.
      # Disabled for performance reasons
      # if waterpoints._links.next
      #   $http.get(waterpoints._links.next.href)
      #     .success addMarkers
    Waterpoint.query
      max_results: 100
      projection:
        _id: 1
        district: 1
        latitude: 1
        longitude: 1
        wpt_code: 1
        wpt_name: 1
        status: 1
    , addMarkers
  .controller 'WaterpointEditCtrl', ($scope, $http, $routeParams, Waterpoint, Form) ->
    Waterpoint.get id: $routeParams.id, (waterpoint) ->
      $scope.waterpoint = waterpoint
    $scope.formTemplate = Form
    $scope.save = () ->
      etag = $scope.waterpoint._etag
      # We need to remove these special attributes since they are not defined
      # in the schema and the data will not validate and the update be rejected
      for attr in ['_created', '_etag', '_id', '_links', '_updated']
        $scope.waterpoint[attr] = undefined
      $http.put('/api/waterpoints/'+$routeParams.id,
                $scope.waterpoint,
                headers: {'If-Match': etag})
        .success (data, status, headers, config) ->
          console.log data, status, headers, config
