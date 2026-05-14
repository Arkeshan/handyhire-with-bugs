import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class NegotiateScreen extends StatefulWidget {
  final Map<String, String> job;
  final int jobIndex;

  const NegotiateScreen({super.key, required this.job, required this.jobIndex});

  @override
  State<NegotiateScreen> createState() => _NegotiateScreenState();
}

class _NegotiateScreenState extends State<NegotiateScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitNegotiation() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {'action': 'remove', 'index': widget.jobIndex});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Negotiate',
              style: TextStyle(
                  color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.job['title']!,
                          style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Customer: ${widget.job['customerName']}',
                          style: TextStyle(
                              color: AppColors.text.withOpacity(0.8), fontSize: 15)),
                      const SizedBox(height: 6),
                      Text('Original Price: ${widget.job['price']}',
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Your Negotiation Amount',
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.secondary,
                    hintText: 'e.g. 3000',
                    hintStyle: TextStyle(color: AppColors.text.withOpacity(0.5)),
                    prefixText: 'Rs. ',
                    prefixStyle: const TextStyle(
                        color: AppColors.accent, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your negotiation amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                const Text('Reason for Negotiation',
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 5,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => FocusScope.of(context).unfocus(),
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.secondary,
                    hintText: 'Explain why you are negotiating...',
                    hintStyle: TextStyle(color: AppColors.text.withOpacity(0.5)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a reason';
                    if (value.length < 10) {
                      return 'Please provide more detail (min 10 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitNegotiation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Finish',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
