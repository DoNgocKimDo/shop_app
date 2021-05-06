import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import '../providers/product.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({Key key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocus = FocusNode();
  final _description = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocus = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _init = true;
  var _initValue = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocus.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_init) {
      final prodId = ModalRoute.of(context).settings.arguments.toString();
      if (prodId != null) {
        _editProduct = Provider.of<Products>(context,listen: false).findById(prodId);
        _initValue = {
          'title': _editProduct.title,
          'price': _editProduct.price.toString(),
          'description': _editProduct.description,
          // 'imageUrl':_editProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    _init = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocus.removeListener(_updateImageUrl);
    _description.dispose();
    _priceFocus.dispose();
    _imageUrlController.dispose();
    _imageUrlFocus.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocus.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('jpeg'))) return;
      setState(() {});
    }
  }

  void _saveForm() {
     final _isValid = _form.currentState.validate();
    if (!_isValid) return;
    _form.currentState.save();
    if (_editProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
      print('update');
    } else {
      Provider.of<Products>(context, listen: false).addProduct(_editProduct);
      print('create');
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit your product'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                _saveForm();
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _initValue['title'],
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  Focus.of(context).requestFocus(_priceFocus);
                },
                onSaved: (newValue) {
                  _editProduct = Product(
                    title: newValue,
                    price: _editProduct.price,
                    imageUrl: _editProduct.imageUrl,
                    description: _editProduct.description,
                    id: _editProduct.id,
                    isFavorite: _editProduct.isFavorite,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) return 'Please enter your Title';
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValue['price'],
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocus,
                onFieldSubmitted: (_) {
                  Focus.of(context).requestFocus(_description);
                },
                onSaved: (newValue) {
                  _editProduct = Product(
                    title: _editProduct.title,
                    price: double.parse(newValue),
                    imageUrl: _editProduct.imageUrl,
                    description: _editProduct.description,
                    id: _editProduct.id,
                    isFavorite: _editProduct.isFavorite,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) return 'Please enter your Price';
                  if (double.parse(value) <= 0)
                    return 'Please enter number greater than 0 ';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValue['description'],
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                focusNode: _description,
                onSaved: (newValue) {
                  _editProduct = Product(
                    title: _editProduct.title,
                    price: _editProduct.price,
                    imageUrl: _editProduct.imageUrl,
                    description: newValue,
                    id: _editProduct.id,
                    isFavorite: _editProduct.isFavorite,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) return 'Please enter your Description';
                  if (value.length < 10)
                    return 'Should be at least 10 characters long';
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 10, right: 8),
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    )),
                    child: _imageUrlController.text.isEmpty
                        ? Text('Enter URL')
                        : FittedBox(
                            child: Image.network(_imageUrlController.text),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocus,
                      onFieldSubmitted: (value) {
                        _saveForm();
                      },
                      onSaved: (newValue) {
                        _editProduct = Product(
                          title: _editProduct.title,
                          price: _editProduct.price,
                          imageUrl: newValue,
                          description: _editProduct.description,
                          id: _editProduct.id,
                          isFavorite: _editProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter your image URL';
                        if ((!value.startsWith('http') &&
                                !value.startsWith('https')) ||
                            (!value.endsWith('.jpg') &&
                                !value.endsWith('.png') &&
                                !value.endsWith('jpeg')))
                          return 'Please enter a valid URL';
                        return null;
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
