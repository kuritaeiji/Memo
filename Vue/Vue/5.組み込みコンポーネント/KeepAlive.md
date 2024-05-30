# KeepAlive コンポーネント

- 複数のコンポーネントを動的に切り替える際にコンポーネントを動的にキャッシュする
- コンポーネントが unmount された後に再度 mount される場合、ref オブジェクトなどの変更された状態が維持される（初期化されない）

## KeepAlive の使用方法

親コンポーネント

```Vue
<script setup lang="ts">
import MyComponent from '../components/MyComponent.vue'
import AnotherComponent from '../components/AnotherComponent.vue'

const currentComponent = ref(MyComponent)
</script>

<template>
  <KeepAlive>
    <component :is="currentComponent" />
    <button @click="() => currentComponent == MyComponent ? AnotherComponent : MyComponent">コンポーネント切り替え</button>
  </KeepAlive>
</template>
```

子コンポーネント（MyComponent）

```Vue
<script setup lang="ts">
const count = ref(0)
</script>

<template>
  <div>
    <div>count: {{ count }}</div>
    <button @click="() => count++">カウントアップ</button>
  </div>
</template>
```

子コンポーネント（AnotherComponent）

```Vue
<script setup lang="ts">
const count = ref(0)
</script>

<template>
  <div>
    <div>count: {{ count }}</div>
    <button @click="count++">カウントアップ</button>
  </div>
</template>
```

上記コードの場合、MyComponent から AnotherComponent に切り替える際に MyComponent をキャッシュする（count の状態もキャシュされる）。その後 AnotherComponent から MyComponent に切り替えると MyComponent ではキャシュした count の値を使用する。

## Include/Exclude

キャッシュするコンポーネントを include または exclude プロパティーを使用してカスタマイズできる。

- include props: 指定したコンポーネントの状態のみキャッシュする
- exclude props: 指定したコンポーネントの状態をキャッシュしない

```HTML
<template>
  <!-- MyComponentのみキャッシュする -->
  <KeepAlive include="MyComponent">
    <component :is="currentComponent" />
  </KeepAlive>

  <!-- MyComponentとAnotherComponentをキャッシュする -->
  <KeepAlive :include="['MyComponent', 'AnotherComponent']">
    <component :is="currentComponent" />
  </KeepAlive>
</template>
```

## キャッシュできるコンポーネントの最大数

- max props を使用するとキャッシュできるコンポーネントの最大数を指定できる
- キャッシュしているコンポーネントの最大数を超える場合、最も過去にアクセスされたキャッシュコンポーネントが破棄される

```HTML
<template>
  <!-- 最大3個のコンポーネントをキャッシュできる -->
  <KeepAlive max="3">
    <component :is="currentComponent" />
  </KeepAlive>
</template>
```

## キャッシュされたコンポーネントのライフサイクル

- コンポーネントがアンマウント(unmount)される代わりに非アクティブ化状態(deactivated)に移行する
- コンポーネントがマウント(mount)される代わりにアクティブ化状態(activated)に移行する
- onActivated フックと onDeactivated フックを onMounted フックと onUnmounted フックの代わりに使用する

```TypeScript
const position = ref({ x: 0, y: 0 })

// onMountedフックを使用すると1回目のマウント時はコールバック関数が実行されるが、再度アクティブ化される際にはコールバック関数が実行されない。
onActivated(() => {
  window.addEventListener('mousemove', (event: Event) => {
    position.value.x = event.pageX
    position.value.y = event.pageY
  })
})

onDeactivated(() => {
  window.removeEventListener('mousemove', (event: Event) => {
    position.value.x = event.pageX
    position.value.y = event.pageY
  })
})
```
