import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'EditScreen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocouseNode = FocusNode();
  final _descFocouseNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageFocuseNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');

  var _isInit = true;

  var _initialValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  var _isLoading = false;
  @override
  void initState() {
    _imageFocuseNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initialValue = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageFocuseNode.removeListener(_updateImageUrl);
    _priceFocouseNode.dispose();
    _descFocouseNode.dispose();
    _imageUrlController.dispose();
    _imageFocuseNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageFocuseNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
        // } finally {
        //   setState(() {
        //     _isLoading = false;
        //   });
        //   Navigator.of(context).pop();
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initialValue['title'],
                        decoration: InputDecoration(labelText: "Title"),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_priceFocouseNode);
                        },
                        onSaved: (value) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              isFavorite: _editProduct.isFavorite,
                              title: value,
                              price: _editProduct.price,
                              description: _editProduct.description,
                              imageUrl: _editProduct.imageUrl);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please provide a value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initialValue['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocouseNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_descFocouseNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'please enter a number greater than zero';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editProduct = Product(
                              title: _editProduct.title,
                              id: _editProduct.id,
                              isFavorite: _editProduct.isFavorite,
                              price: double.parse(value),
                              description: _editProduct.description,
                              imageUrl: _editProduct.imageUrl);
                        },
                      ),
                      TextFormField(
                        initialValue: _initialValue['description'],
                        decoration: InputDecoration(labelText: "Description"),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descFocouseNode,
                        onSaved: (value) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              isFavorite: _editProduct.isFavorite,
                              title: _editProduct.title,
                              price: _editProduct.price,
                              description: value,
                              imageUrl: _editProduct.imageUrl);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter a description';
                          }
                          if (value.length < 10) {
                            return 'Should be atleast 10 character long';
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter a Url')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image url'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageFocuseNode,
                              onFieldSubmitted: (_) => _saveForm(),
                              onSaved: (value) {
                                _editProduct = Product(
                                    id: _editProduct.id,
                                    isFavorite: _editProduct.isFavorite,
                                    title: _editProduct.title,
                                    price: _editProduct.price,
                                    description: _editProduct.description,
                                    imageUrl: value);
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "please enter a imageurl";
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return "please enter a valid Url";
                                }
                                if (!value.endsWith('.jpg') &&
                                    !value.endsWith('.png') &&
                                    !value.endsWith('.jpeg')) {
                                  return "please enter a valid imageUrl";
                                }
                                return null;
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
