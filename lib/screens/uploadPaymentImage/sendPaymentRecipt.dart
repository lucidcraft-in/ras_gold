import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/colo_extension.dart';
import '../../providers/goldrate.dart';
import '../../providers/paymentBill.dart';

class SendPaymentRec extends StatefulWidget {
  const SendPaymentRec({super.key});

  @override
  State<SendPaymentRec> createState() => _SendPaymentRecState();
}

class _SendPaymentRecState extends State<SendPaymentRec> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  DateTime? _selectedDate;
  String? _pickedFile;
  File? selectedFile;
  bool checkValue = false;
  var user;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _graRateController = TextEditingController();

  Map<String, dynamic> qrDetailsData = {};
  bool _isQrDetailsLoading = true;
  bool _isAccountDetailsExpanded = false;

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    checkValue = prefs.containsKey('user');
    if (checkValue == true) {
      setState(() {
        var data = prefs.getString("user");
        // print(data);
        setState(() {
          user = jsonDecode(data!);
        });
      });
    }
    Provider.of<Goldrate>(context, listen: false).read().then((value) {
      setState(() {
        var rate = value![0]["gram"].toDouble();
        goldRate = rate;
        _graRateController.text = goldRate.toString();
      });
    });
  }

  double goldRate = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    fetchData();
    fetchQrDetails();
  }

  Map<String, dynamic> aboutUsData = {};
  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('aboutUs').limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          aboutUsData = data;
        });
      } else {}
    } catch (e) {}
  }

  Future<void> fetchQrDetails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('QRdetails')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          qrDetailsData = data;
          _isQrDetailsLoading = false;
        });
      } else {
        setState(() {
          _isQrDetailsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isQrDetailsLoading = false;
      });
    }
  }

  void _copyToClipboard(String text, String fieldName) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName copied to clipboard'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: TColo.primaryColor2,
        ),
      );
    });
  }

  void _launchWhatsApp() async {
    String phone = "91${aboutUsData["phone"]}";
    // String phone = "919961624063";
    // Compose a meaningful WhatsApp message with product details
    String message = '''Name : ${user["name"]}
Customer Id : ${user["custId"]}
Hello, I have completed the payment. Please find the screenshot attached for your reference.
''';

    // Encode message for URL
    String whatsappUrl =
        "https://wa.me/$phone/?text=${Uri.encodeComponent(message)}";

    try {
      final Uri url = Uri.parse(whatsappUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F5F1),
        appBar: AppBar(
          title: const Text(
            'Upload Screenshot',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF460218),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF460218),
                  const Color(0xFF460218),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                _buildInfoCard(),
                const SizedBox(height: 10),
                // Account Details Expandable Dropdown
                _buildAccountDetailsWidget(),
                const SizedBox(height: 10),
                // Form Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Amount Field
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter valid amount';
                            }
                            return null;
                          },
                          focusNode: _amountFocusNode,
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: "Amount",
                            labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                            hintText: 'Enter Amount',
                            prefixIcon: Icon(
                              Icons.currency_rupee_rounded,
                              color: const Color(0xFF460218),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50]!,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: TColo.primaryColor2, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Note Field
                        TextFormField(
                          focusNode: _noteFocusNode,
                          controller: _noteController,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            labelText: "Note / Description",
                            labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                            hintText: 'Enter Note',
                            prefixIcon: Icon(
                              Icons.description_outlined,
                              color: const Color(0xFF460218),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50]!,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: TColo.primaryColor2, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Gram Rate Field
                        TextFormField(
                          readOnly: true,
                          controller: _graRateController,
                          style: TextStyle(
                              color: const Color(0xFF460218),
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                          decoration: InputDecoration(
                            labelText: "Current Gram Rate",
                            labelStyle: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500),
                            prefixIcon: Icon(
                              Icons.monetization_on_outlined,
                              color: const Color(0xFF460218),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100]!,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Date Selector
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: TColo.primaryColor2,
                                      onPrimary: Colors.white,
                                      onSurface: TColo.primaryColor2,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              TimeOfDay currentTime = TimeOfDay.now();
                              setState(() {
                                _selectedDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  currentTime.hour,
                                  currentTime.minute,
                                );
                              });
                            }
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    color: const Color(0xFF460218), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDate == null
                                        ? 'Select Payment Date'
                                        : DateFormat('dd MMM yyyy, hh:mm a')
                                            .format(_selectedDate!),
                                    style: TextStyle(
                                      color: _selectedDate == null
                                          ? Colors.grey[600]
                                          : Colors.black,
                                      fontWeight: _selectedDate == null
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down,
                                    color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Screenshot Upload Container
                        GestureDetector(
                          onTap: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              setState(() {
                                _pickedFile = result.files.single.name;
                                selectedFile = File(result.files.single.path!);
                              });
                            }
                          },
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: TColo.primaryColor2.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _pickedFile != null
                                    ? const Color(0xFF460218).withOpacity(0.3)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: _pickedFile == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: TColo.primaryColor1
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.cloud_upload_outlined,
                                          color: TColo.primaryColor1,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Upload Payment Screenshot',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: TColo.primaryColor2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap to browse files (Images or PDFs)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Builder(builder: (context) {
                                          final isImage = _pickedFile!
                                                  .toLowerCase()
                                                  .endsWith('.jpg') ||
                                              _pickedFile!
                                                  .toLowerCase()
                                                  .endsWith('.jpeg') ||
                                              _pickedFile!
                                                  .toLowerCase()
                                                  .endsWith('.png');
                                          return Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey[200],
                                              image: isImage
                                                  ? DecorationImage(
                                                      image: FileImage(
                                                          selectedFile!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: isImage
                                                ? null
                                                : const Icon(
                                                    Icons
                                                        .insert_drive_file_outlined,
                                                    size: 32,
                                                    color: Colors.grey,
                                                  ),
                                          );
                                        }),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _pickedFile!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'File selected successfully',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _pickedFile = null;
                                              selectedFile = null;
                                            });
                                          },
                                          icon: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Submit Button
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF460218),
                                const Color(0xFF460218).withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: TColo.primaryColor2.withOpacity(0.24),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _submitFor,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Submit Screenshot',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColo.primaryColor2.withOpacity(0.08),
            TColo.primaryColor1.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColo.primaryColor2.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: TColo.primaryColor2,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Receipt Submission',
                  style: TextStyle(
                    color: TColo.primaryColor2,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please fill in the details of your payment and upload a clear screenshot of the transaction.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsWidget() {
    if (_isQrDetailsLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (qrDetailsData.isEmpty) {
      return const SizedBox.shrink();
    }

    final String accountNo =
        qrDetailsData['acNo'] ?? qrDetailsData['ac_no'] ?? '';
    final String ifsc = qrDetailsData['ifsc'] ?? '';
    final String upiId = qrDetailsData['upiId'] ?? '';
    final String? qrCodeUrl = qrDetailsData['qrcode'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isAccountDetailsExpanded
              ? TColo.primaryColor2.withOpacity(0.3)
              : Colors.grey[200]!,
          width: _isAccountDetailsExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(_isAccountDetailsExpanded ? 0.06 : 0.02),
            blurRadius: _isAccountDetailsExpanded ? 12 : 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Click to expand)
          InkWell(
            onTap: () {
              setState(() {
                _isAccountDetailsExpanded = !_isAccountDetailsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TColo.primaryColor2.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_outlined,
                      color: TColo.primaryColor2,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Payment Account & QR Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isAccountDetailsExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isAccountDetailsExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F3F3)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (accountNo.isNotEmpty) ...[
                    _buildCopyableRow('Account Number', accountNo),
                    const SizedBox(height: 12),
                  ],
                  if (ifsc.isNotEmpty) ...[
                    _buildCopyableRow('IFSC Code', ifsc),
                    const SizedBox(height: 12),
                  ],
                  if (upiId.isNotEmpty) ...[
                    _buildCopyableRow('UPI ID', upiId),
                    const SizedBox(height: 16),
                  ],
                  if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) ...[
                    const Text(
                      'Scan QR Code to Pay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            qrCodeUrl,
                            height: 180,
                            width: 180,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                height: 180,
                                width: 180,
                                child: Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 180,
                                width: 180,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined,
                                        color: Colors.grey, size: 40),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load QR code',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCopyableRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copyToClipboard(value, label),
            icon: Icon(
              Icons.copy_rounded,
              color: TColo.primaryColor2,
              size: 20,
            ),
            tooltip: 'Copy $label',
          ),
        ],
      ),
    );
  }

  void _submitFor() async {
    setState(() {
      _isSubmitting = true;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    if (_formKey.currentState!.validate() &&
        _pickedFile != null &&
        _selectedDate != null) {
      Provider.of<PaymentBillProvider>(context, listen: false)
          .addPayment(
              double.parse(_amountController.text),
              _noteController.text,
              goldRate,
              _selectedDate!,
              selectedFile!,
              _pickedFile!,
              user)
          .then((val) async {
        // print(val);
        if (val == 200) {
          // Handle successful submission
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() {
            _isSubmitting = false;
          });
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Screenshot Submitted Successfully')),
          );
          _launchWhatsApp();

          // Clear form
          // _amountController.clear();
          // _noteController.clear();
          setState(() {
            _pickedFile = null;
            _selectedDate = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('An error occurred. Please try again.')),
          );
        }
      });
    } else {
      setState(() {
        _isSubmitting = false;
      });
      const snackBar = SnackBar(content: Text("Please fill out all fields"));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Set focus back to the first empty field if necessary
      // if (_amountController.text.isEmpty) {
      //   _amountFocusNode.requestFocus();
      // } else if (_noteController.text.isEmpty) {
      //   _noteFocusNode.requestFocus();
      // }
    }
  }

  // FocusNodes
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();
  @override
  void dispose() {
    // Dispose controllers and FocusNodes
    _amountController.dispose();
    _noteController.dispose();
    _graRateController.dispose();
    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }
}
