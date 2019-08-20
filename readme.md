# Bean Utils v1.0.10
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v1.0.10](http://img.shields.io/badge/pod-v1.0.10-yellow.svg)](http://eggbox.fantomfactory.org/pods/afBeanUtils)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

*Bean Utils is a support library that aids Alien-Factory in the development of other libraries, frameworks and applications. Though you are welcome to use it, you may find features are missing and the documentation incomplete.*

`Bean Utils` is a collection of utilities and software patterns for overcoming common issues associated with data objects.

Features include:

- **Bean Identity**

  Generate `equals()`, `hash()` and `toStr()` methods from annotated fields.


- **Bean Properties**

  Get and set object properties and call methods via `property expressions`.


- **Type Coercer**

  Convert objects, lists and maps from one type to another using Fantom's standard `toXXX()` and `fromXXX()` methods.


- **More!**

  Utility methods to find matching ctors and methods.



`Bean Utils` is loosely named after [JavaBeans](http://www.oracle.com/technetwork/java/javase/documentation/spec-136004.html),

## Install

Install `Bean Utils` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afBeanUtils

Or install `Bean Utils` with [fanr](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afBeanUtils

To use in a [Fantom](http://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afBeanUtils 1.0"]

## Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afBeanUtils/) - the Fantom Pod Repository.

## Bean Identity

Nobody likes writing `hash()` and `equals()` methods, so let [BeanIdentity](http://eggbox.fantomfactory.org/pods/afBeanUtils/api/BeanIdentity) take the pain away! Simply annotate important identity fields with `@BeanId` and override the Obj methods.

Sample usage:

```
class User {
  @BeanId Int? id
  @BeanId Str? name
          Str? notUsed

  override Int hash() {
    BeanIdentity.beanHash(this)
  }

  override Bool equals(Obj? obj) {
    BeanIdentity.beanEquals(this, obj)
  }

  override Str toStr() {
    BeanIdentity.beanToStr(this)
  }
}
```

## Bean Properties

[BeanProperties](http://eggbox.fantomfactory.org/pods/afBeanUtils/api/BeanProperties) is a nifty way to get and set properties, and call methods, on nested objects.

Properties are accessed via a *property expression*. Property expressions look like Fantom code and may traverse many objects. Their main purpose is to get and set properties, but may be used to call methods also.

```
string := "100 101 102"
BeanProperties.call(string, "split[1].get(2).plus(2).toChar") // --> 3
```

Using `BeanProperties` and a bit of naming convention care, it now becomes trivial to populate an object with properties submitted from a HTTP form:

```
formBean := BeanProperties.create(MyFormBean#, httpReq.form)
```

Features of property expressions include:

### Field Access

The simplest use case is getting and setting basic fields. In this example we access the field `Buf.capacity`:

```
buf := Buf()
BeanProperties.get(buf, "capacity")     // --> 16
BeanProperties.set(buf, "capacity", 42) // set a new value
```

When setting fields, the given value is [Type Coerced](http://eggbox.fantomfactory.org/pods/afBeanUtils/api/TypeCoercer) to fit the field type. Consider:

```
BeanProperties.set(buf, "charset", "UTF-16")  // string "UTF-16" is converted to a Charset object
```

### Method Calls

Property expressions can call methods too. Like Fantom code, if the method does not take any parameters then brackets are optional:

```
buf := Buf()
BeanProperties.call(buf, "flush")
BeanProperties.call(buf, "flush()")
```

Method arguments may also form part of the expression, and like property values, are type coerced to their respective types:

```
BeanProperties.call(buf, "fill(255, 4)")    // --> 0xFFFFFFFF
BeanProperties.call(buf, "getRange(1..2)")  // --> 0xFFFF
```

Or you may pass arguments in:

```
BeanProperties.call(buf, "fill", [128, 4])      // --> 0x80808080
BeanProperties.call(buf, "getRange()", [1..2])  // --> 0x8080
```

### Indexed Properties

Lists, Maps and `@Operator` shortcuts for `get` and `set` may all be traversed using square bracket notation:

```
list := Str?["a", "b", "c"]
BeanProperties.get(list, "[1]") // --> "b"
```

All keys and values are [Type Coerced](http://eggbox.fantomfactory.org/pods/afBeanUtils/api/TypeCoercer) to the correct type.

#### Lists

When setting List items special attention is given make sure they don't throw `IndexErrs`. Should the list size be smaller than the given index, the list is automatically grown to accommodate:

```
list := Str?[,]
BeanProperties.set(list, "[1]", "b")
list.size                            // --> 2
list[0]                              // --> null
list[1]                              // --> "b"
```

If the list items are *not* nullable, then new objects are created:

```
list := Str[,]
BeanProperties.set(list, "[1]", "b")
list.size                            // --> 2
list[0]                              // --> ""
list[1]                              // --> "b"
```

### Chaining

Property expressions become very powerful when chained:

    obj.method(arg, arg).map[key].list[idx][operator].field

### Object Creation

When traversing a property expression, the last thing you want is a `NullErr` half way through. With that in mind, should a property expression encounter `null` part way through, a new object is created and set.

Now you can happily chain your expressions with confidence!

#### Advanced

If you need more control over when and how intermediate objects are created, then use `BeanPropertyFactory` to manually parse property expressions and create your own `BeanProperty` instances.

