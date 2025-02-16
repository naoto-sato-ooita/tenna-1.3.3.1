{\rtf1\ansi\ansicpg932\cocoartf2761
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 // swift-tools-version:5.5\
\
import PackageDescription\
\
let package = Package(\
    name: "YourProjectName",\
    platforms: [\
        .iOS(.v14)\
    ],\
    products: [],\
    dependencies: [\
        .package(name: "GeoFire", url: "https://github.com/firebase/geofire-objc.git", from: "4.1.0"),\
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0.0")\
    ],\
    targets: []\
)\
}