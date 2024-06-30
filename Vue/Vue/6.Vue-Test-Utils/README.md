# Vue-Test-Utils

- 単体テスト: 1 つのコンポーネントのみをテストする（子コンポーネントをスタブする）
- 結合テスト: 複数のコンポーネントをテストする（子コンポーネントをスタブしない）

## VueTestUtils の重要な関数とオブジェクト

- mount 関数: コンポーネントをマウントして、テスト用のメソッドを追加したコンポーネントのラッパー（VueWrapper）を返却する。
- VueWrapper オブジェクト: コンポーネントインスタンスをラップするラッパー。コンポーネントにテストに役立つメソッドを追加する。
- vm オブジェクト: Vue インスタンスのメソッドとプロパティーにアクセスできる。
- flushPromises 関数: 全ての未解決の Promise を解決する。
- nextTick 関数: 本物の DOM を更新するマイクロタスクを全て実行する。
- config.global オブジェクト: テストスイート全体に対してマウントオプションを設定する。

## mount 関数

```TypeScript
function mount(Component, options?: MountingOptions): VueWrapper

interface MountingOptions<Props, Data = {}> {
  attachTo?: Element | string
  props?: (RawProps & Props) | ({} extends Props ? null : never)
  slots?: { [key: string]: Slot } & { default?: Slot }
  global?: GlobalMountOptions
  shallow?: boolean
}

type GlobalMountOptions = {
  plugins?: (Plugin | [Plugin, ...any[]])[]
  config?: Partial<Omit<AppConfig, 'isNativeTag'>>
  provide?: Record<any, any>
  components?: Record<string, Component | object>
  directives?: Record<string, Directive>
  stubs?: Stubs = Record<string, boolean | Component> | Array<string>}
```

- 第 1 引数に指定したコンポーネントをマウントする
- 第 2 引数に指定したオプションを Vue インスタンスやコンポーネントに設定する
  - attachTo: 指定した DOM にコンポーネントをマウントする
  - props: コンポーネントのプロパティーを指定する
  - slots: コンポーネントのスロットを指定する
  - global: Vue インスタンスに対するグローバルな設定を指定する（プラグインやグローバルコンポーネントの指定など）
    - plugins: プラグインを指定する
    - config: errorHandler/warnHandler/globalProperties を指定できる
    - provide: InjectionKey と use 関数から返却されるオブジェクトなどをモックしたものを指定する
    - components: グローバル登録するコンポーネントを指定する
    - directives: directive を指定する
    - stubs: スタブしたいコンポーネントを指定する
  - shallow: true を指定すると shallowMount する。shallowMount すると全てのコンポーネントとスロットをスタブする

## VueWrapper の find メソッドと get メソッド

- find/get メソッドはともにテスト用のメソッドを追加した`DOMWrapper`を返却する
- find メソッドは DOM が見つからなかった場合に`ErrorWrapper`を返却する
- get メソッドは DOM が見つからなかった場合にエラーを throw する

## v-if と v-show のテスト

### v-if

1. findComponent や find メソッドで DOMWrapper を取得する
2. DOMWrapper.exists()メソッドで DOM が存在するかテストする

### v-show

1. findComponent や find メソッドで DOMWrapper を取得する
2. DOMWrapper.isVisible()メソッドで DOM が表示されているかテストする

## イベントのテスト

1. DOMWrapper.trigger()メソッドを使用してイベントを発行する
2. `expect(VueWrapper.emitted('イベント名')).toEqual([[arg1, arg2]])`で発行したイベント名と引数が一致するか確認する

emitted メソッドが返却するオブジェクト例

```TypeScript
{
  event1: [
    ['arg1', 'arg2'], // 1回目のイベント
    ['arg1', 'arg2'] // 2回目のイベント
  ],
  event2: [
    ['arg1', 'arg2']
  ]
}
```

## DOM の状態のテスト

ユーザーのクリックなどの操作で仮想 DOM を更新する場合は、本物の DOM が更新されるまで待つ必要がある。仮想 DOM は同期的に更新されるが、本物の DOM の更新は非同期（マイクロタスク）で実行される。また、テストは同期的に実行されてしまうため、DOM 更新のマイクロタスクを強制的に実行させた後に expect 関数で DOM の状態をテストする必要がある。

### 1. await DOMWrapper.setValue()/VueWrapper.setProps()/DOMWrapper.trigger()メソッドを使用する

setValue メソッドや setProps メソッドは Promise オブジェクトを返却する。この Promise オブジェクトは DOM の更新のマイクロタスクの実行が終了すると Fullfilled 状態になるのでメソッドから返却される Promise オブジェクトを await することで DOM 更新が完了するまで待つことができる。

```TypeScript
await wrapper.setProps({ modelValue: 'newVal' })
expect(wrapper.emitted('update:model-value')).toEqual([['newVal']])
```

### 2. nextTick 関数を使用する

nextTick 関数は DOM を更新すると Fullfilled 状態になる Promise を返却する。この Promise を await することで nextTick 関数以降のコードが DOM 更新後にマイクロタスクとして実行される。

```TypeScript
const wrapper = mount(ExampleComponent) // ExampleComponentはマウント後に仮想DOMを操作する
await nextTick()
expect(wrapper.text()).toContain('example')
```

### 3. flushPromises 関数を使用する

flushPromises 関数はコンポーネント内の全ての Promise（外部 API 呼び出しなど） が Fullfilled 状態になると Fullfilled 状態になる Promise を返却する。よって DOM の更新時にも一応使用可能だが、基本的には API を呼び出す際の Promise が完了するまで待つために使用する。

## フォームのテスト

DOMWrapper.setValue メソッドを使用して値をセットする

```TypeScript
const wrapper = mount(Form)
await wrapper.find('input').setValue('newVal') // DOMが更新するまで待つためにawaitする
expect(wrapper.find('input')).toBe('newVal')
```

## プロパティーを渡す・更新する

- 初期プロパティー: mount 関数の第 2 引数のオプションとして指定する
- プロパティーの更新: VueWrapper.setProps メソッドを使用する

```TypeScript
const wrapper = mount(Example, {
  props: {
    modelValue: 'val'
  }
})
await wrapper.setProps({ modelValue: 'newVal' })
```

## スロット

mount 関数の第 2 引数のオプションとして指定する

```TypeScript
const wrapper = mount(Example, {
  slots: {
    default: '<div></div>',
    item: defineComponent({
      template: `
      <template #item="item">
        {{ item.name }}
      </template>
      `
    })
  }
})
await wrapper.setProps({ modelValue: 'newVal' })
```

## asyns setup コンポーネント

asyns setup を使用するコンポーネントは親コンポーネントとして Suspense コンポーネントが必要

```TypeScript
const TestComponent = defineComponent({
  components: { AsyncComponent },
  template: `
  <Suspense><AsyncComp /></Suspense>
  `
})

const wrapper = mount(TestComponent)
// ここでSuspenseのfallbackコンテンツを確認する
await flushPromises()
// ここで非同期処理完了後のコンテンツを確認する
```

## Vue ルーターのテスト

- useRoute と useRouter メソッドをスタブする
- RouterLink コンポーネントを RouterLinkStub コンポーネントでスタブする

```TypeScript
config.global.stubs = {
  RouterLink: RouterLinkStub
}
config.global.provide = {
  [routerKey as symbol]: {
    push: vi.fn(),
    replace: vi.fn()
  }
}

const wrapper = mount(Example, {
  global: {
    provide: {
      [routeLocationKey as symbol]: {
        params: {
          userId: 1
        },
        query: {
          meta: 'meta'
        }
      }
    }
  }
})
```
