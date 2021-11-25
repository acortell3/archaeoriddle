import { Transformer } from 'markmap-lib';

const transformer = new Transformer();

// 1. transform markdown
const { root, features } = transformer.transform(markdown);

// 2. get assets
// either get assets required by used features
const { styles, scripts } = transformer.getUsedAssets(features);
// or get all possible assets that could be used later
const { styles, scripts } = transformer.getAssets();

