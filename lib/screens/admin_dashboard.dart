import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../config/app_validators.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../services/manual_reply_service.dart';
import '../services/conversation_chat_service.dart';
import '../utils/responsive.dart';
import '../widgets/rbac_visibility.dart';
import '../widgets/app_dialogs.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const String _msgSubAdminNotFound =
    'User not found. Ask the user to register first, then assign Sub-Admin role.';
  static const String _msgSubAdminGranted =
    'Sub-Admin access granted successfully.';
  static const String _msgSubAdminGrantFailed =
    'Failed to assign Sub-Admin role: ';
  static const String _msgUserNotFound = 'User not found.';
  static const String _msgNotSubAdmin = 'This user is not a Sub-Admin.';
  static const String _msgSubAdminRemoved =
    'Sub-Admin access removed successfully.';
  static const String _msgSubAdminRemoveFailed =
    'Failed to remove Sub-Admin role: ';
  static const String _msgValidPrice = 'Please enter a valid price.';
  static const String _msgProductAdded = 'Product added successfully!';

  final _formKey = GlobalKey<FormState>();
  final _subAdminFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();
  final _subAdminEmailCtrl = TextEditingController();
  final _subAdminNameCtrl = TextEditingController();
  final _manualKeywordCtrl = TextEditingController();
  final _manualReplyCtrl = TextEditingController();
  final _adminCustomerUidCtrl = TextEditingController();
  final _adminCustomerReplyCtrl = TextEditingController();
  final _manualReplyFormKey = GlobalKey<FormState>();
  final ManualReplyService _manualReplyService = ManualReplyService();
  final ConversationChatService _conversationChatService =
      ConversationChatService();

  bool _loading = false;
  bool _subAdminLoading = false;
  bool _manualReplyLoading = false;
  bool _adminReplyLoading = false;
  bool _success = false;
  String? _newProductId;
  bool _showSuccessDialog = false;
  String? _editingManualReplyId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    _categoryCtrl.dispose();
    _reviewCtrl.dispose();
    _subAdminEmailCtrl.dispose();
    _subAdminNameCtrl.dispose();
    _manualKeywordCtrl.dispose();
    _manualReplyCtrl.dispose();
    _adminCustomerUidCtrl.dispose();
    _adminCustomerReplyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendAdminReplyToCustomer(AuthService auth) async {
    final customerUid = _adminCustomerUidCtrl.text.trim();
    final message = _adminCustomerReplyCtrl.text.trim();
    if (customerUid.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer UID and reply message are required.'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _adminReplyLoading = true);
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(customerUid)
          .get();

      if (!userDoc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer not found for this UID.'),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }

      final userData = userDoc.data() ?? <String, dynamic>{};
      final customerName = (userData['name'] ?? '').toString();
      final customerEmail = (userData['email'] ?? '').toString();

      final conversationId = await _conversationChatService.ensureCustomerConversation(
        customerId: customerUid,
        customerName: customerName,
        customerEmail: customerEmail,
      );

      final senderName = auth.profile?.name.trim().isNotEmpty == true
          ? auth.profile!.name
          : (auth.user?.email ?? 'Admin');

      await _conversationChatService.sendMessage(
        conversationId: conversationId,
        senderId: auth.user?.uid ?? 'admin',
        senderRole: AppConstants.adminRole,
        senderName: senderName,
        text: message,
      );

      _adminCustomerReplyCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply sent to customer.'),
          backgroundColor: AppTheme.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reply: $e'),
          backgroundColor: AppTheme.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _adminReplyLoading = false);
      }
    }
  }

  Future<void> _saveManualReply(AuthService auth) async {
    if (!(_manualReplyFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final role = (auth.profile?.role ?? AppConstants.subAdminRole).trim();
    final keyword = _manualKeywordCtrl.text.trim();
    final reply = _manualReplyCtrl.text.trim();
    final isEditing = _editingManualReplyId != null;

    setState(() => _manualReplyLoading = true);

    try {
      if (_editingManualReplyId == null) {
        await _manualReplyService.createReply(
          keyword: keyword,
          reply: reply,
          createdBy: role,
        );
      } else {
        await _manualReplyService.updateReply(
          _editingManualReplyId!,
          keyword: keyword,
          reply: reply,
          createdBy: role,
        );
      }

      _manualKeywordCtrl.clear();
      _manualReplyCtrl.clear();
      _editingManualReplyId = null;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Manual reply updated.'
                : 'Manual reply saved.',
          ),
          backgroundColor: AppTheme.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save manual reply: $e'),
          backgroundColor: AppTheme.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _manualReplyLoading = false);
      }
    }
  }

  void _beginManualReplyEdit(String id, Map<String, dynamic> data) {
    setState(() {
      _editingManualReplyId = id;
      _manualKeywordCtrl.text = (data['keyword'] ?? '').toString();
      _manualReplyCtrl.text = (data['reply'] ?? '').toString();
    });
  }

  Future<void> _deleteManualReply(String id) async {
    final confirmed = await AppDialog.showConfirmationDialog(
      context,
      title: 'Delete Manual Reply',
      message: 'Are you sure you want to delete this manual reply?',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      await _manualReplyService.deleteReply(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manual reply deleted.'),
          backgroundColor: AppTheme.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete manual reply: $e'),
          backgroundColor: AppTheme.red,
        ),
      );
    }
  }

  Future<void> _handleAddSubAdmin() async {
    if (!(_subAdminFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _subAdminEmailCtrl.text.trim().toLowerCase();
    final name = _subAdminNameCtrl.text.trim();

    // Show confirmation dialog before granting admin access
    final confirmed = await AppDialog.showConfirmationDialog(
      context,
      title: 'Grant Admin Access',
      message: 'Are you sure you want to grant Admin access to $email?',
      confirmLabel: 'Grant Access',
      cancelLabel: 'Cancel',
      isDestructive: false,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _subAdminLoading = true);

    try {
      final users =
          FirebaseFirestore.instance.collection(AppConstants.usersCollection);
      final snapshot =
          await users.where('email', isEqualTo: email).limit(1).get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(_msgSubAdminNotFound),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }

      final doc = snapshot.docs.first;
      final updateData = <String, dynamic>{
        'role': AppConstants.subAdminRole,
      };
      if (name.isNotEmpty) {
        updateData['name'] = name;
      }

      await users.doc(doc.id).update(updateData);

      _subAdminEmailCtrl.clear();
      _subAdminNameCtrl.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_msgSubAdminGranted),
          backgroundColor: AppTheme.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_msgSubAdminGrantFailed$e'),
          backgroundColor: AppTheme.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _subAdminLoading = false);
      }
    }
  }

  Future<void> _handleRemoveSubAdmin() async {
    final email = _subAdminEmailCtrl.text.trim().toLowerCase();
    final emailError = AppValidators.email(email);
    if (emailError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError), backgroundColor: AppTheme.red),
      );
      return;
    }

    setState(() => _subAdminLoading = true);

    try {
      final users =
          FirebaseFirestore.instance.collection(AppConstants.usersCollection);
      final snapshot =
          await users.where('email', isEqualTo: email).limit(1).get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(_msgUserNotFound),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }

      final doc = snapshot.docs.first;
      final currentRole = (doc.data()['role'] ?? AppConstants.customerRole)
          .toString()
          .trim();

      if (currentRole != AppConstants.subAdminRole) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(_msgNotSubAdmin),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }

      await users.doc(doc.id).update({'role': AppConstants.customerRole});

      _subAdminEmailCtrl.clear();
      _subAdminNameCtrl.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_msgSubAdminRemoved),
          backgroundColor: AppTheme.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_msgSubAdminRemoveFailed$e'),
          backgroundColor: AppTheme.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _subAdminLoading = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final parsedPrice = double.tryParse(_priceCtrl.text.trim());
    if (parsedPrice == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_msgValidPrice),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _success = false;
    });

    try {
      final docRef = await FirebaseFirestore.instance
          .collection(AppConstants.productsCollection)
          .add({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': parsedPrice,
        'imageUrl': _imageCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'review': _reviewCtrl.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _newProductId = docRef.id;
        _showSuccessDialog = true;
        _success = true;
      });

      _nameCtrl.clear();
      _descCtrl.clear();
      _priceCtrl.clear();
      _imageCtrl.clear();
      _categoryCtrl.clear();
      _reviewCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isAdmin = auth.isAdmin;
    final isStrictAdmin = auth.profile?.role == AppConstants.adminRole;
    final isMobile = context.isMobile;
    final horizontalPadding = context.responsivePadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                    Text('Admin Dashboard',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 30,
                        fontWeight: FontWeight.w900,
                      color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                    Text(
                      'Manage your store inventory and add new products.',
                      style: TextStyle(color: AppTheme.textDark, fontSize: isMobile ? 14 : 15)),
                    const SizedBox(height: 12),
                    if (isAdmin)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppConstants.adminChatRoute),
                          icon: const Icon(Icons.forum_outlined),
                          label: const Text('Open Admin Inbox'),
                        ),
                      ),
                    SizedBox(height: isMobile ? 20 : 28),

                  // Form card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.borderGray),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.06),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: AppTheme.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Text('Add New Product',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_success) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.green.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    color: AppTheme.green, size: 18),
                                SizedBox(width: 8),
                                Text(_msgProductAdded,
                                    style: TextStyle(
                                        color: AppTheme.green,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        isMobile
                            ? Column(
                                children: [
                                  _FormField(
                                    controller: _nameCtrl,
                                    label: 'Product Name *',
                                    hint: 'e.g. Wireless Mouse',
                                    icon: Icons.inventory_2_outlined,
                                    validator: AppValidators.productName,
                                  ),
                                  const SizedBox(height: 16),
                                  _FormField(
                                    controller: _categoryCtrl,
                                    label: 'Category *',
                                    hint: 'e.g. Electronics',
                                    icon: Icons.label_outline_rounded,
                                    validator: AppValidators.category,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _FormField(
                                      controller: _nameCtrl,
                                      label: 'Product Name *',
                                      hint: 'e.g. Wireless Mouse',
                                      icon: Icons.inventory_2_outlined,
                                      validator: AppValidators.productName,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _FormField(
                                      controller: _categoryCtrl,
                                      label: 'Category *',
                                      hint: 'e.g. Electronics',
                                      icon: Icons.label_outline_rounded,
                                      validator: AppValidators.category,
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: _priceCtrl,
                          label: 'Price (\$) *',
                          hint: '99.99',
                          icon: Icons.attach_money_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: AppValidators.price,
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: _imageCtrl,
                          label: 'Image URL *',
                          hint: 'https://images.unsplash.com/...',
                          icon: Icons.image_outlined,
                          keyboardType: TextInputType.url,
                          onChanged: (_) => setState(() {}),
                          validator: AppValidators.url,
                        ),
                        const SizedBox(height: 16),
                        if (_imageCtrl.text.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.bgGray,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.borderGray),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: isMobile ? 60 : 72,
                                    height: isMobile ? 60 : 72,
                                    child: CachedNetworkImage(
                                      imageUrl: _imageCtrl.text,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        color: AppTheme.borderGray,
                                        child: const Icon(
                                            Icons.broken_image_outlined,
                                            color: AppTheme.textGray),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 10 : 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('LIVE PREVIEW',
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            color: AppTheme.textDark,
                                              letterSpacing: 1)),
                                      const SizedBox(height: 4),
                                      Text(
                                        _nameCtrl.text.isEmpty
                                            ? 'Product Name'
                                            : _nameCtrl.text,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          color: AppTheme.textDark),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '\$${_priceCtrl.text.isEmpty ? '0.00' : _priceCtrl.text}',
                                        style: const TextStyle(
                                          color: AppTheme.textDark,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _FormField(
                          controller: _descCtrl,
                          label: 'Description *',
                          hint: 'Tell us about the product...',
                          icon: Icons.description_outlined,
                          maxLines: 4,
                          validator: AppValidators.description,
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: _reviewCtrl,
                          label: 'Featured Review (Optional)',
                          hint: 'Add a featured review or testimonial...',
                          icon: Icons.star_outline_rounded,
                          maxLines: 3,
                          validator: AppValidators.review,
                        ),
                        SizedBox(height: isMobile ? 20 : 24),
                        RbacVisibility(
                          isAdmin: isAdmin,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _handleSubmit,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5))
                                  : const Icon(Icons.add_rounded),
                              label: Text(
                                  _loading ? 'Adding...' : 'Add Product',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isAdmin) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderGray),
                      ),
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.reply_all_rounded,
                                  color: AppTheme.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Admin Reply Box',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter customer UID and send a direct admin reply.',
                            style: TextStyle(color: AppTheme.textDark, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            controller: _adminCustomerUidCtrl,
                            label: 'Customer UID *',
                            hint: 'Paste customer Firebase UID',
                            icon: Icons.person_outline_rounded,
                            validator: (value) => null,
                          ),
                          const SizedBox(height: 14),
                          _FormField(
                            controller: _adminCustomerReplyCtrl,
                            label: 'Reply Message *',
                            hint: 'Type your reply to customer...',
                            icon: Icons.chat_bubble_outline_rounded,
                            maxLines: 4,
                            validator: (value) => null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _adminReplyLoading
                                  ? null
                                  : () => _sendAdminReplyToCustomer(auth),
                              icon: _adminReplyLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                _adminReplyLoading ? 'Sending...' : 'Send Reply',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (isStrictAdmin) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderGray),
                      ),
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Form(
                        key: _subAdminFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings_outlined,
                                    color: AppTheme.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Add Sub-Admin',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sub-admin users have the same permissions as admins.',
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _FormField(
                              controller: _subAdminEmailCtrl,
                              label: 'User Email *',
                              hint: 'user@example.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: AppValidators.email,
                            ),
                            const SizedBox(height: 14),
                            _FormField(
                              controller: _subAdminNameCtrl,
                              label: 'Display Name (Optional)',
                              hint: 'Name in profile',
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) return null;
                                return AppValidators.name(value);
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _subAdminLoading
                                    ? null
                                    : _handleAddSubAdmin,
                                icon: _subAdminLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.admin_panel_settings_outlined,
                                      ),
                                label: Text(
                                  _subAdminLoading
                                      ? 'Granting Access...'
                                      : 'Manage Staff',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _subAdminLoading
                                    ? null
                                    : _handleRemoveSubAdmin,
                                icon: const Icon(
                                  Icons.person_remove_alt_1_outlined,
                                  color: AppTheme.red,
                                ),
                                label: const Text(
                                  'Remove Sub-Admin',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.red,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side:
                                      const BorderSide(color: AppTheme.red),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.borderGray),
                    ),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Form(
                      key: _manualReplyFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.quickreply_outlined,
                                  color: AppTheme.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Manual Chat Replies',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Define keyword-based replies. Example: keyword "hello" reply "Hi there!"',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _FormField(
                            controller: _manualKeywordCtrl,
                            label: 'Keyword *',
                            hint: 'e.g. hey, hello, how are you',
                            icon: Icons.tag_rounded,
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty) return 'Keyword is required.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _FormField(
                            controller: _manualReplyCtrl,
                            label: 'Reply Message *',
                            hint: 'Hi there! How can I help you?',
                            icon: Icons.message_outlined,
                            maxLines: 3,
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty) return 'Reply message is required.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _manualReplyLoading
                                      ? null
                                      : () => _saveManualReply(auth),
                                  icon: _manualReplyLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(_editingManualReplyId == null
                                          ? Icons.save_outlined
                                          : Icons.edit_outlined),
                                  label: Text(
                                    _editingManualReplyId == null
                                        ? 'Save Reply'
                                        : 'Update Reply',
                                  ),
                                ),
                              ),
                              if (_editingManualReplyId != null) ...[
                                const SizedBox(width: 10),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _editingManualReplyId = null;
                                      _manualKeywordCtrl.clear();
                                      _manualReplyCtrl.clear();
                                    });
                                  },
                                  child: const Text('Cancel Edit'),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _manualReplyService.watchReplies(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(color: AppTheme.primary),
                                  ),
                                );
                              }

                              final docs = snapshot.data?.docs ?? [];
                              if (docs.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'No manual replies yet. Add your first keyword reply above.',
                                    style: TextStyle(color: AppTheme.textPrimary),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: docs.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  final data = doc.data();
                                  final keyword = (data['keyword'] ?? '').toString();
                                  final reply = (data['reply'] ?? '').toString();
                                  final createdBy = (data['createdBy'] ?? '-').toString();

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgGray,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppTheme.borderGray),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Keyword: $keyword',
                                                style: const TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _beginManualReplyEdit(doc.id, data),
                                              icon: const Icon(Icons.edit_outlined, size: 20),
                                              tooltip: 'Edit',
                                            ),
                                            IconButton(
                                              onPressed: () => _deleteManualReply(doc.id),
                                              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.red, size: 20),
                                              tooltip: 'Delete',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          reply,
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Created by: $createdBy',
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quick Tips',
                            style: TextStyle(
                            color: AppTheme.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        ...[
                          'Use high-quality Unsplash URLs for product images.',
                          'Keep descriptions concise but informative.',
                          'Categories help users filter products easily.',
                        ].map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(
                                        top: 6, right: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(tip,
                                        style: const TextStyle(
                                        color: AppTheme.textDark,
                                            fontSize: 13,
                                            height: 1.5)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Success dialog overlay
          if (_showSuccessDialog)
            _SuccessDialog(
              productId: _newProductId ?? '',
              onViewProduct: () {
                setState(() => _showSuccessDialog = false);
                Navigator.pushNamed(context, Routes.product.path,
                    arguments: _newProductId);
              },
              onAddAnother: () => setState(() => _showSuccessDialog = false),
              onBackHome: () {
                setState(() => _showSuccessDialog = false);
                Navigator.pushReplacementNamed(context, Routes.home.path);
              },
            ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int? maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines,
    this.keyboardType,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
            color: AppTheme.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines ?? 1,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.textGray, size: 20),
            alignLabelWithHint: maxLines != null && maxLines! > 1,
          ),
        ),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final String productId;
  final VoidCallback onViewProduct;
  final VoidCallback onAddAnother;
  final VoidCallback onBackHome;

  const _SuccessDialog({
    required this.productId,
    required this.onViewProduct,
    required this.onAddAnother,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.all(isMobile ? 16 : 32),
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.green, size: 44),
              ),
              const SizedBox(height: 20),
                Text('Product Added!',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w900,
                    color: AppTheme.textDark)),
              const SizedBox(height: 8),
              const Text(
                'Your new item is now live on the store for all customers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textDark, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewProduct,
                  child: const Text('View Product'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAddAnother,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bgGray,
                    foregroundColor: AppTheme.textDark,
                  ),
                  child: const Text('Add Another'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onBackHome,
                child: const Text('Back to Home',
                  style: TextStyle(color: AppTheme.textDark, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
