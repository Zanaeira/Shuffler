# Shuffler

This app allows the user to create lists of items that they can then shuffle. It is currently in the [App Store](https://apps.apple.com/gb/app/shuffler/id1608246757).

Teachers can use it to create an arbitrary order for their students to perform tasks in. Users can make a list of recipes based on the ingredients they have in stock, and then generate a random list to decide what to cook today, or for the rest of the week. It can be used for any kind of list that a user would like to shuffle, or to just get a random item from the list.

## Table of Contents

  * [Architecture](#architecture)
    + [MVC](#mvc)
    + [Modularity](#modularity)
    + [Dependency Injection](#dependency-injection)
    + [Protocol-oriented programming](#protocol-oriented-programming)
  * [TDD](#tdd)
  * [Programmatic UIKit](#programmatic-uikit)
    + [AutoLayout](#autolayout)
    + [Modern Collection Views](#modern-collection-views)
  * [Accessibility](#accessibility)
  * [Contact](#contact)

## Architecture

This app makes use of the following good architectural practices:

### MVC

The app is coded using MVC. The underlying data models are decoupled from their representation in the Cache layer via use of a private Codable type and mapping across the modules; increasing modularity and ensuring that clients do not break on changes.

### Modularity

The app is modular in a number of ways. The project is split into a framework and a main app. The framework consists of a number of targets to help modularise the different components. This necessitated sensible and reasonable use of access modifiers in order to keep internal and private details safely away from the main app / other components.

The framework has targets for
1. The Caching layer
2. The Unit tests for the Caching layer
3. The iOS target - iOS specific components / view controllers that speak to the Networking layer via its public interface / API and without any access to its internal implementation details

The main app serves as the Composition Root in which the iOS App is brought together in a UINavigationController.

### Dependency Injection

In the Composition Root, the app is composed by injecting the dependencies into the ViewControllers. This means that there is flexibility to change the underlying implementations for these dependencies without any need to make changes in the framework or other modules. The ViewControllers are separated and decoupled from each other as Navigation is handled by the composing type. Thus, the ViewControllers are stand-alone and can be reused independently.


### Protocol-oriented programming

The Caching layer uses protocols to abstract details for the loading and amending of Lists and Items. Thus, the usage of Codable and the FileSystem becomes an implementation detail that the rest of the module, and other modules, have no knowledge of. This means that the Caching could be replaced with something like CoreData without breaking anything else.

## TDD

The Caching module was developed using Test-Driven Development. Unit tests have been used to ensure that the behaviour is as expected, as well as to protect from regressions.

## Programmatic UIKit

The entire user interface has been coded using programmatic UIKit. Storyboards have not been used other than for the launch screen.

### AutoLayout

AutoLayout has been used throughout this App, programmatically. In the launch screen, AutoLayout has been used in the Storyboard.

### Modern Collection Views

The UICollectionView APIs from iOS 13/14 have been used. Namely:
* DiffableDataSource
* CompositionalLayout
* UICollectionViewListCell
* SupplementaryRegistration
* UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider
* UICellAccessory

## Accessibility

This app makes use of Dynamic Type in order to provide a good, accessible experience for people who are visually impaired or simply prefer to use larger font sizes on their phone.

## Contact
If you have any questions please do not hesitate to contact me on: suhayl.ahmed@icloud.com
