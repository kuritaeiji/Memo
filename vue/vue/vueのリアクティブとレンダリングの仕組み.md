# Vue のリアクティブとレンダリングの仕組み

## レンダリングの流れ

WebpackなどでビルドしてVueテンプレートを仮想DOMに変換する  
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;↓  
HTMLからJavaScriptファイルを読み込みルートコンポーネントを指定してVueインスタンスを作成する  
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;↓  
Vueインスタンスをマウントする。（仮想 DOM ツリーを走査し、実際の DOM を作成しマウントする。走査中にリアクティブオブジェクトのゲッターを使用することでtrack関数が実行されSubscriber（購読者）が登録される）  
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;↓  
リアクティブオブジェクト更新（リアクティブオブジェクトを更新すると仮想 DOM を更新し、レンダラーが実際の DOM を作成し更新する。リアクティブオブジェクトのセッター関数を使用することでtrigger関数を実行し、Subscriber 関数を実行し、仮想 DOM を更新している）

```typescript
// 仮想DOM
const renderFn = () => ({
  type: 'div',
  props: {
    id: 'hello'
  },
  children: [
    {
      type: 'div'
    }
  ]
})
```

## リアクティブオブジェクト

```typescript
const reactive = (target: any) => {
  return new Proxy(target, {
    get(obj, property) {
      track(obj, property)
      // track関数は以下のようなSubscribersオブジェクトにSubscriberを追加する
      // {
      //   property1: {
      //     key1: [
      //       updateFn // 仮想DOMを更新する関数
      //     ]
      //   },
      //   property2: {
      //     key2: []
      //   }
      // }
      return obj[property]
    },
    set(obj, property, value) {
      obj[property] = value
      trigger(obj, property)
      // trigger関数はsubscribers[obj][property]に登録されているSubscribersを実行する
      // subscribers[obj][property].forEach(subscriber => subscriber())
    }
  })
}

const ref = (target: any) => {
  const refObj = {
    value: target,
    get value() {
      track(refObj, 'value')
      // track関数は以下のようなSubscribersオブジェクトにSubscriberを追加する
      // {
      //   refObj1: {
      //     value: [updateRefObj1] // 仮想DOMを更新する関数
      //   },
      //   refObj2: {
      //     value: [updateRefObj2]
      //   }
      // }
      return value
    },
    set value(newValue) {
      value = newValue
      trigger(refObj, 'value')
      // trigger関数はsubscribers[refObj].valueに登録されているsubscriberを実行する
      // subscribers[refObj].value.forEach(subscriber => subscriber())
    }
  }
}
```

track 関数は仮想 DOM から実際の DOM にレンダリングされる際に実行される。  
trigger 関数は ref,reactive オブジェクトが更新されると実行され、仮想 DOM を更新する。

## 参考 URL

- [リアクティブの仕組み](https://ja.vuejs.org/guide/extras/reactivity-in-depth.html)
- [レンダリングの仕組み](https://ja.vuejs.org/guide/extras/rendering-mechanism.html)
