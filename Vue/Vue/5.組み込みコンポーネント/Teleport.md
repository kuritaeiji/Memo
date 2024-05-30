# Teleport コンポーネント

Teleport コンポーネントのデフォルトスロットに渡されたテンプレートを、Teleport コンポーネントの DOM 階層の外側に存在する任意の DOM ノードに挿入できるコンポーネント。

## モーダルの使用例

モーダルコンポーネント（Modal.vue）

```Vue
<script setup lang="ts">
import { inject, onUnmounted, ref } from 'vue'
import { useModals, useModalsKey } from '../composables/useModals'

const { modalCount, plusModalCount, minusModalCount } = inject(
  useModalsKey
) as ReturnType<typeof useModals>

const isShow = ref(false)
const zIndex = ref(0)
const openModal = () => {
  if (isShow.value) {
    return
  }
  isShow.value = true
  // モーダルを開いたときにコンポーザブル関数で管理するモーダル数を+1する
  plusModalCount()
  zIndex.value = modalCount.value + 10
}
const closeModal = () => {
  if (!isShow.value) {
    return
  }
  isShow.value = false
  // モーダルを閉じたときにコンポーザブル関数で管理するモーダル数を-1する
  minusModalCount()
}

// アンマウント時にコンポーザブル関数で管理するモーダル数を-1する
onUnmounted(() => {
  minusModalCount()
})
</script>

<template>
  <div>
    <slot
      name="activator"
      :openModal="openModal"
    />
    <Teleport
      v-if="isShow"
      to="#modals"
    >
      <div
        class="modal"
        :style="{ zIndex }"
      >
        <slot :closeModal="closeModal" />
      </div>
    </Teleport>
  </div>
</template>
```

コンポーザブル関数（useModals.ts）

```TypeScript
import { InjectionKey, ref } from 'vue'

const useModals = () => {
  const modalCount = ref(0)

  const plusModalCount = () => {
    modalCount.value += 1
  }

  const minusModalCount = () => {
    modalCount.value -= 1
  }

  return { modalCount, plusModalCount, minusModalCount }
}

const useModalsKey: InjectionKey<ReturnType<typeof useModals>> = Symbol()

export { useModals, useModalsKey }
```

main.ts

```TypeScript
const app = createApp(App)
app.provide(useModalsKey, useModals())
```

Modal コンポーネントを使用する親コンポーネント

```HTML
<template>
  <div>
    <Modal>
      <!-- スコープ付きスロットでopenModal関数を受け取る -->
      <template #activator="{ openModal }">
        <button @click="openModal">開く</button>
      </template>

      <!-- スコープ付きスロットでcloseModal関数を受け取る -->
      <template #default="{ closeModal }">
        <button @click="closeModal">閉じる</button>
      </template>
    </Modal>

    <Modal>
      <template #activator="{ openModal }">
        <button @click="openModal">開く</button>
      </template>

      <template #default="{ closeModal }">
        <button @click="closeModal">閉じる</button>
      </template>
    </Modal>
  </div>
</template>
```

- アプリケーション全体で共通のコンポーザブル関数を使用して表示されているモーダル数を管理する（複数のモーダルを開いた場合に z-index を管理するため）
- モーダルを開いた場合、モーダルを閉じた場合、モーダルコンポーネントが画面遷移などで DOM ツリーからアンマウントされた場合にコンポーザブル関数で管理するモーダル数を+1 または-1 する
- モーダルコンポーネントは親コンポーネントから activator スロット（モーダルを開くテンプレート）と default スロット（モーダル自体のテンプレート）を受け取る
- activator スロットは親コンポーネントに openModal 関数をスコープ付きスロットで渡し、default スロットは親コンポーネントに closeModal 関数をスコープ付きスロットで渡す（親コンポーネントで定義したスロットコンテンツ内で openModal 関数や closeModal 関数を使用てほしいため）
- default スロットで受けっとたテンプレートは id=modals を付与した HTML 要素にテレポートさせる

## テレポートを無効化する

Teleport コンポーネントの disabled props に true を立たすことでテレポートを無効化できる。

```HTML
<template>
  <Teleport disabled="true">
    ...
  </Teleport>
</template>
```
