import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

bool isValidImageUrl(String url) {
  if (url.isEmpty) {
    return false;
  }
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return false;
  }
  if (!url.endsWith('.jpeg') &&
      !url.endsWith('.jpg') &&
      !url.endsWith('.png')) {
    return false;
  }
  return true;
}

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // To use the next button, need to have one for each field
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  //Controller created to update the image without submitting the form
  final _imageUrlController = TextEditingController();
  //Focus node to make sure the image is updated when I lose focus
  final _imageUrlFocusNode = FocusNode();
  //Key to save form
  final _form = GlobalKey<FormState>();

  var _isInit = true;

  // Form variables
  String? id;
  String _title = '';
  double _price = 0;
  String _description = '';
  String _imageUrl =
      'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/2019-honda-civic-sedan-1558453497.jpg';
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    //I create this listener to make sure the image updates if I lose focus of
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //I had to make this to extract the arguments and work with the provider
    //because I cannot do it from initState as the context is not loaded there.
    //Another solution would  be to use Future.delayed(Duration.zero) but feels
    //to messy imho and I read  it doesn't work with provider. If I only needed
    //the arguments I could use onRouteChanged in the MaterialApp
    if (_isInit) {
      id = ModalRoute.of(context)!.settings.arguments as String?;
      print(id);
      if (id != null && id!.isNotEmpty) {
        var _editedProduct =
            Provider.of<Products>(context, listen: false).findById(id!);
        _title = _editedProduct.title;
        _description = _editedProduct.description;
        _price = _editedProduct.price;
        _imageUrl = _editedProduct.imageUrl;
        _isFavorite = _editedProduct.isFavorite;
      }
      _isInit = false;

      // I cant assign initial value and controller to the same field
      _imageUrlController.text = _imageUrl;
    }
    super.didChangeDependencies();
  }

  ///Check if the focusnode lost focus to trigger the setState and show the new
  ///image
  void _updateImageUrl() {
    //if (!_imageUrlFocusNode.hasFocus && isValidImageUrl(_imageUrl)) {
    if (!_imageUrlFocusNode.hasFocus &&
        isValidImageUrl(_imageUrlController.text)) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (isValid == null || !isValid) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    var _product = Product(
        id: id ?? '',
        title: _title,
        description: _description,
        price: _price,
        imageUrl: _imageUrl,
        isFavorite: _isFavorite);

    if (id == null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_product);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error ocurred!'),
                  content: Text('Something went wrong'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('OK'))
                  ],
                ));
      } finally {
        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      Provider.of<Products>(context, listen: false)
          .updateProduct(id!, _product);
      Navigator.of(context).pop();
    }
    //Navigator.of(context).pop();
  }

  // Always dispose the focus nodes after using!!
  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
                _saveForm();
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(label: Text('Title')),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _title = value ?? _title;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                      initialValue: _title,
                    ),
                    TextFormField(
                      decoration: InputDecoration(label: Text('Price')),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      initialValue: _price == 0 ? '' : _price.toString(),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _price = value != null
                            ? double.tryParse(value) ?? _price
                            : _price;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price cannot be empty';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Price should be a valid number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(label: Text('Description')),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _description = value ?? _description;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description cannot be empty';
                        }
                        return null;
                      },
                      initialValue: _description,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              //child: _imageUrl.isEmpty
                              ? Align(child: Text('Enter a URL'))
                              : Image.network(
                                  //_imageUrl,
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Align(
                                      child: Text(
                                        'URL is not valid',
                                        textAlign: TextAlign.center,
                                      ),
                                      alignment: Alignment.center,
                                    );
                                  },
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                InputDecoration(label: Text('Image URL')),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageUrlFocusNode,
                            controller: _imageUrlController,
                            onFieldSubmitted: (value) {
                              if (isValidImageUrl(value)) {
                                setState(() {
                                  //_imageUrl = value;
                                });
                              }
                            },
                            onSaved: (value) {
                              _imageUrl = value ?? _imageUrl;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'URL cannot be empty';
                              }
                              if (!isValidImageUrl(value)) {
                                return 'Image is not a valid image URL';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
