import { withDefaults } from '@warp-drive/legacy/model/migration-support';

export default withDefaults({
  type: 'pokemon',

  fields: [
    { name: 'name', kind: 'attribute' },
    { name: 'sprite', kind: 'attribute' },
    { name: 'types', kind: 'attribute' },
  ],
});
