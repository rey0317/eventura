import CoreLocation

struct Booth: Identifiable {
    let id: String
    let title: String
    let location: CLLocationCoordinate2D
    var isScanned: Bool = false
}

var sampleBooths: [Booth] = [
    Booth(id: "1", title: "Booth 1", location: CLLocationCoordinate2D(latitude: 42.270506029056634, longitude: -83.74339895330718), isScanned: false),
    Booth(id: "2", title: "Booth 2", location: CLLocationCoordinate2D(latitude: 42.270506029056634, longitude: -83.74339895330718), isScanned: false),
    Booth(id: "3", title: "Booth 3", location: CLLocationCoordinate2D(latitude: 42.270506029056634, longitude: -83.74339895330718), isScanned: false),
    Booth(id: "4", title: "Booth 4", location: CLLocationCoordinate2D(latitude: 42.270506029056634, longitude: -83.74339895330718), isScanned: false)
]

/*
var sampleBooths: [Booth] = [
Booth(id: "1", title: "Booth 1", location: CLLocationCoordinate2D(latitude: 42.270506029056634, longitude: -83.74339895330718), isScanned: false),
Booth(id: "2", title: "Booth 2", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), isScanned: false),
Booth(id: "3", title: "Booth 3", location: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298), isScanned: false),
Booth(id: "4", title: "Booth 4", location: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), isScanned: false)
]
*/



