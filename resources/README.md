# Docs for the View section of this project

> This file is a short **documentation** for the `/resources` section of a Laravel project. <br>
> For the docs of the whole project, visit the [repository](https://github.com/andrejnano/IIS-projekt)

<br>
<b>THE PRIMARY USE OF THIS DIRECTORY IS TO PROVIDE A SEPARATED VIEW MODEL<br>FROM THE DATA MODEL AND BUSINESS LOGIC ON THE BACKEND</b>
<br><br>
<em>Architecture inspiration: </em> <a href='https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel'> Model–view–viewmodel</a>
<br>

**`/resources` structure:**

- [`components`](#components)
- [`design`](#design)
- [`lang`](#lang)
- [`utils`](#utils)
- [`views`](#views)
- [`app.js`](#appjs)
- [`App.vue`](#Appvue)

<br> 

## `components`

[Vue.js components](https://vuejs.org/v2/guide/components.html)

Each component contains a HTML template, Javascript funcionality attached to it and a stylesheet.

<br> 

## `design`

Stylesheets, color pallets, layout setting, fonts.. UI in general

Mostly written in SCSS/SASS/CSS.

<br> 

## `lang`

Laravel translations.

<br> 

## `utils`

Generic javascript utilities and small modules, that are not dealing with the user interface, but instead calculate or assert general data.

<br> 

## `views`

Views directory holds all the compositions/scenes of other smaller components with a semantic value as a whole.
Also, this directory should be used for storing static pages.

<br> 

## `app.js`

The main **entry point** for the whole web application. This file is loaded to the HTML website and includes all packages, components, directives for rendering and most importantly - the Vue framework.

<br> 

## `App.vue`

This is the root component of the web application, all other components are loaded underneath this one.

Contains a 2 children components:

- Navigation
- Router View

Both work together thanks to a Vue plugin - Vue Router, which handles routes and replaces components instead of refreshing the whole web page.
