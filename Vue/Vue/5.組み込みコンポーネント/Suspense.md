# Suspense コンポーネント

Suspense コンポーネントはコンポーネントツリー内にある複数のネストされた非同期な依存関係が解決されるのを待つ間ローディング状態をレンダリングできる

## 非同期な依存関係とは

Suspense が待ち受けることができる非同期な依存関係は以下の 2 種類。

1. `<script setup>`内で await を使用する
2. [非同期コンポーネント](../4.コンポーネント/8.非同期コンポーネント.md)

## Suspense コンポーネントの使用方法

- Suspense コンポーネントは`#default`と`#fallback`という 2 つのスロットを持つ
- `#default`スロットには表示すべきコンテンツを記述する
- `#fallback`スロットにはローディング時に表示したいコンテンツを記述する

子コンポーネント（Post.vue）

```Vue
<script setup>
const res = await fetch(...)
const posts = await res.json()
</script>

<template>
  {{ posts }}
</template>
```

親コンポーネント

```HTML
<template>
  <Suspense>
    <Post />
    <template #fallback>
      Loading...
    </template>
  </Suspense>
</template>
```

## Suspense のライフサイクル

1. 初回レンダリング時にデフォルトスロットのコンテンツをメモリー上にレンダリングし、非同期な依存関係が存在した場合に Suspense コンポーネントを Pending 状態にする。
2. Pending 状態の場合はフォルバックコンテンツを表示する
3. 全ての非同期な依存関係が解決すると Suspense コンポーネントは resolved 状態になる
4. 一旦 resolved 状態になった Suspense コンポーネントはデフォルトスロットのルートノードが置換された場合にのみ pending 状態になる
5. 再度 pending 状態になった場合はフォールバックコンテンツをすぐに表示せず、timeout props で指定した時間が経過しても resolved 状態にならなかった場合のみフォールバックコンテンツを表示する

## イベント

Suspense コンポーネントは pending resolve fallback の 3 種類のイベントを発行する

- pending イベント: Suspense コンポーネントが pending 状態になったときに発行される
- resolve イベント: Suspense コンポーネントが Resolved 状態になったときに発行される
- fallback イベント: fallback スロットのコンテンツを表示したときに発行される

## エラーハンドリング

Suspense の default スロットコンテンツ内の Promise オブジェクトが Rejected 状態になった際に onErrorCaptured フックを使用してエラーを補足できる

```Vue
<script setup lang="ts">
// onErrorCapturedフックのコールバック関数のerror引数にはPromiseがRejected状態になった際に渡されるエラーオブジェクトを表す。
onErrorCaptured((error) => {
  console.log(error)
})
</script>

<template>
  <Suspense>
    <Post />
    <template #fallback>
      Loading...
    </template>
  </Suspense>
</template>
```

## ネストした Suspense

```HTML
<template>
  <Suspense>
    <component :is="DynamicAsyncOuter">
      <component :is="DynamicAsyncInner" />
    </component>
  </Suspense>
</template>
```

上記コードの場合、初回レンダリング時は全ての非同期コンポーネントが解決されるまで fallback スロットコンテンツを表示する。ただし、一旦 Resolved 状態になった Suspense コンポーネントはルートノードが変化した場合のみ再度 Pending 状態になり fallback コンテンツを表示する。よって OuterComponent を変更した場合は fallback コンテンツを表示するが、InnerComponent を変更した場合はルートノードの変更ではないので fallback コンテンツを表示しない。  
これを直すにはネストした非同期コンポーネントを Suspense コンポーネントルートノードにするために Suspense コンポーネントをもう一つ記述する。

```HTML
<template>
 <Suspense>
    <component :is="DynamicAsyncOuter">
      <Suspense suspensible> <!-- これを追加する -->
        <component :is="DynamicAsyncInner" />
      </Suspense>
    </component>
  </Suspense>
</template>
```

## vue-router と組み合わせる

```HTML
<template>
  <!-- デフォルトスロットのスコープ付きスロットでRouterViewコンポーネントからURLにマッチするcomponentを受け取る -->
  <RouterView v-slot="{ component }">
    <!-- Suspenseコンポーネントはデフォルトスロットのルートノード（今回の場合は動的コンポーネント）が置換されるたびにPending状態になりfallbackコンテンツを表示する -->
    <!-- SuspenseコンポーネントがPending状態になってからtimeout propsに設定したms経過後にfallbackコンテンツを表示するため0秒にすることで、URL変更後すぐにfallbackコンテンツを表示する -->
    <Suspense timeout="0">
      <!-- 動的コンポーネントでURLにマッチしたコンポーネントを表示する -->
      <component :is="component" />

      <template #fallback>
        Loading...
      </template>
    </Suspense>
  </RouterView>
</template>
```

Suspense コンポーネントのルートノードが置換されると、Suspense コンポーネントは再度 Pending 状態になる。よって default スロットのルートノードを動的コンポーネントにすることでルートノードが置換され fallback コンテンツが表示されるようにする。timeout props を設定することでルートノードが置換され再度 Pending 状態になったときに即座に fallback コンテンツが表示されるようにしている

## 疑似コード

以下 Suspense を使用した場合の`<script setup>`を Vue ランタイムがマウントするまでの疑似コード

```TypeScript
// 実行順序
(async () => {
  // 1
  const res = await fetch(...)
  // 3
  const posts = await res.json()
})()
  .then(() => {
    // 4
    unmountFallback()
    mountComponent()
  })

// 2
mountFallback()
```

`<script setup>`内のコードは setup ライフサイクル時に実行される。トップレベルに await を記述すると await で指定した Promise オブジェクトが Resolve されるのを待ってから mount ライフサイクルに移行する。（setup 以下に記述されたコードは async 即時実行関数として実行され、全ての Promise オブジェクトが Resolved になるまでは fallback スロットのコンテンツをマウントする。関数内の全ての Promise オブジェクトが Resolved された後に async 即時実行関数が返却する Promise オブジェクトが Pending から Fullfilled になり、マイクロタスクとして発行された then メソッド内のコールバック関数が fallback スロットをアンマウントし、default スロットをマウントする）
